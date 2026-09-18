#!/usr/bin/env bash
set -euo pipefail

: "${DRY_RUN:=false}"
: "${YES:=false}"
: "${VERBOSE:=false}"
: "${PARSED_ARGS:=false}"
: "${COMMON_AUTO_PARSE:=true}"
: "${ACCEPT_POSITIONAL:=false}"
WANT_ALL=false
POSITIONAL_ARGS=()
: "${DOTFILES_DIR:=$HOME/dotfiles}"
: "${REPO_URL:=https://github.com/LarsGielen/dotfiles}"

# --- Colors (only when writing to a terminal) ---
if [ -t 1 ]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_DIM=$'\033[2m'
    C_BLUE=$'\033[34m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'
else
    C_RESET='' C_BOLD='' C_DIM='' C_BLUE='' C_GREEN='' C_YELLOW='' C_RED=''
fi

info() { echo "${C_BLUE}::${C_RESET} $*"; }
ok() { echo "${C_GREEN}✓${C_RESET} $*"; }
warn() { echo "${C_YELLOW}!${C_RESET} $*" >&2; }
die() {
    echo "${C_RED}✗${C_RESET} $*" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Required command '$1' not found"
}

# True inside a WSL distro. The Microsoft kernel tag is present for every WSL
# kernel; $WSL_DISTRO_NAME is only set in shells wsl.exe started itself, so it
# misses sudo, cron and anything re-execed.
is_wsl() {
    [[ "$(cat /proc/sys/kernel/osrelease 2>/dev/null)" == *[Mm]icrosoft* ]]
}

# Run a command, honoring --dry-run.
run_cmd() {
    if [ "${DRY_RUN}" = true ]; then
        echo "[DRY-RUN] $*"
    else
        "$@"
    fi
}

# Run a command, hiding its output unless it fails (or --verbose/--dry-run).
# On failure the captured output is replayed to stderr so errors aren't lost.
# Sudo prompts are avoided by priming credentials first (see prime_sudo).
run_quiet() {
    if [ "${VERBOSE}" = true ] || [ "${DRY_RUN}" = true ]; then
        run_cmd "$@"
        return
    fi

    local tmp rc=0
    tmp="$(mktemp)"
    if "$@" >"$tmp" 2>&1; then
        rm -f "$tmp"
    else
        rc=$?
        cat "$tmp" >&2
        rm -f "$tmp"
    fi
    return "$rc"
}

# run_remote_installer <url> [interpreter]
# Pipe a vendor's install script into an interpreter (bash by default), quietly.
# run_quiet can't wrap a pipeline directly -- it would capture the curl half
# and feed the interpreter nothing -- so the whole pipe runs in one bash -c.
run_remote_installer() {
    local url="$1" interp="${2:-bash}"
    if [ "${DRY_RUN}" = true ]; then
        echo "[DRY-RUN] curl $url | $interp"
        return 0
    fi
    # shellcheck disable=SC2016 # expanded by the inner bash, from its args
    run_quiet bash -c 'curl -fsSL "$1" | "$2"' _ "$url" "$interp"
}

# Cache sudo credentials up front so quiet/captured commands never block on a
# hidden password prompt. No-op under --dry-run.
prime_sudo() {
    [ "${DRY_RUN}" = true ] && return 0
    sudo -v
}

# --- live progress ---------------------------------------------------------
# run_quiet keeps scrollback clean but goes completely silent until a command
# finishes, so a multi-GiB download (cuda, in the blender module) is
# indistinguishable from a hang. run_progress runs the command on a pty -- so
# pacman/yay emit the progress bar they only print to a terminal -- and renders
# it as a single line that redraws in place. Nothing is left behind: the line is
# erased on success, and the full log is replayed only on failure.

SPINNER_FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
PROGRESS_INTERVAL=0.15
PROGRESS_BAR_WIDTH=18

# Human-readable elapsed time: 9s / 4m12s / 1h04m
fmt_duration() {
    local s="$1"
    if [ "$s" -ge 3600 ]; then
        printf '%dh%02dm' "$((s / 3600))" "$(((s % 3600) / 60))"
    elif [ "$s" -ge 60 ]; then
        printf '%dm%02ds' "$((s / 60))" "$((s % 60))"
    else
        printf '%ds' "$s"
    fi
}

_term_cols() {
    local cols
    cols="$(tput cols 2>/dev/null)"
    [[ "$cols" =~ ^[0-9]+$ ]] || cols=80
    echo "$cols"
}

# _progress_bar <percent> -> ▕████████░░░░▏
_progress_bar() {
    local pct="$1" filled rest f e
    filled=$((pct * PROGRESS_BAR_WIDTH / 100))
    [ "$filled" -gt "$PROGRESS_BAR_WIDTH" ] && filled="$PROGRESS_BAR_WIDTH"
    [ "$filled" -lt 0 ] && filled=0
    rest=$((PROGRESS_BAR_WIDTH - filled))
    printf -v f '%*s' "$filled" ''
    printf -v e '%*s' "$rest" ''
    printf '▕%s%s%s%s%s▏' "$C_BLUE" "${f// /█}" "$C_DIM" "${e// /░}" "$C_RESET"
}

# Last meaningful line of the log: the pty rewrites its progress bar with \r, so
# split on both terminators, drop ANSI escapes, and keep the last non-empty one.
_progress_tail() {
    tail -c 4096 "$1" 2>/dev/null | awk '
        BEGIN { RS = "[\r\n]" }
        { gsub(/\033\[[0-9;?]*[a-zA-Z]/, ""); if (NF) last = $0 }
        END { print last }
    '
}

# Draw one frame: spinner, plus pacman/yay's own percentage as our bar when the
# line carries one, otherwise just whatever it last printed.
_progress_draw() {
    local log="$1" frame="$2" cols="$3"
    local raw desc pct max parts=()

    raw="$(_progress_tail "$log")"
    # ' cuda-12.8.1-1-x86_64  3.1 GiB  12.4 MiB/s 00:04 [###----] 61%'
    # Any bar content is accepted, so this doesn't hinge on pacman's fill chars.
    if [[ "$raw" =~ ^[[:space:]]*(.*[^[:space:]])[[:space:]]+\[[^]]*\][[:space:]]*([0-9]+)% ]]; then
        desc="${BASH_REMATCH[1]}"
        pct="${BASH_REMATCH[2]}"
    else
        desc="$raw"
        pct=""
    fi

    # Squeeze the column padding pacman uses to align its bar.
    read -r -a parts <<<"$desc"
    desc="${parts[*]}"

    if [ -n "$pct" ]; then
        # spinner + space + bar(width+2) + space + "100%" + space
        max=$((cols - PROGRESS_BAR_WIDTH - 11))
        [ "$max" -lt 1 ] && max=1
        printf '\r\033[K%s %s %3d%% %s' \
            "$frame" "$(_progress_bar "$pct")" "$pct" "${desc:0:$max}"
    else
        max=$((cols - 3))
        [ "$max" -lt 1 ] && max=1
        printf '\r\033[K%s %s' "$frame" "${desc:0:$max}"
    fi
}

_progress_abort() {
    printf '\r\033[K\033[?25h'
    exit 130
}

# run_progress <cmd>...  -> run with a live one-line progress display.
# Falls back to run_cmd under --verbose/--dry-run (full output is the point
# there) and to run_quiet when stdout isn't a terminal, so piping to a file
# never collects redraw escapes.
run_progress() {
    if [ "${DRY_RUN}" = true ] || [ "${VERBOSE}" = true ]; then
        run_cmd "$@"
        return
    fi
    if [ ! -t 1 ] || ! command -v script >/dev/null 2>&1; then
        run_quiet "$@"
        return
    fi

    local log cmd cols pid rc=0 i=0 as_root=()

    # sudo's credential cache is keyed to the terminal (tty_tickets, sudo's
    # default), so the ticket prime_sudo caches on our terminal does not apply
    # inside the pty script(1) creates -- pacman would prompt for a password
    # behind the progress line, where it can't be answered. Authenticate out
    # here on the real terminal and let script itself run as root.
    if [ "$1" = sudo ]; then
        as_root=(sudo)
        shift
        prime_sudo
    fi

    log="$(mktemp)"
    cols="$(_term_cols)"
    printf -v cmd '%q ' "$@"

    trap 'rm -f "$log"; _progress_abort' INT
    printf '\033[?25l' # hide cursor while we redraw

    # script(1) gives the child a pty; -e propagates its exit status. stdin is
    # closed: a backgrounded reader of the terminal is stopped with SIGTTIN the
    # moment anything is typed, so a command that wants input has to fail loudly
    # (with its log replayed) rather than hang behind the progress line.
    # SHELL is pinned because script runs the command through it, and the login
    # shell here is zsh -- the command string is built with bash's %q quoting.
    SHELL=/bin/bash "${as_root[@]}" script -qec "$cmd" /dev/null >"$log" 2>&1 </dev/null &
    pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        _progress_draw "$log" "${SPINNER_FRAMES[i % ${#SPINNER_FRAMES[@]}]}" "$cols"
        i=$((i + 1))
        sleep "$PROGRESS_INTERVAL"
    done
    wait "$pid" || rc=$?

    printf '\r\033[K\033[?25h'
    trap - INT

    if [ "$rc" -ne 0 ]; then
        # Replay the log without the pty's carriage returns and escapes.
        sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' "$log" | tr '\r' '\n' >&2
    fi
    rm -f "$log"
    return "$rc"
}

# True if a package is already installed (works for repo and AUR packages).
is_installed() {
    pacman -Qq "$1" >/dev/null 2>&1
}

# Shared install logic: report what's already present, install the rest quietly.
_install_pkgs() {
    local manager="$1"
    shift
    local missing=() pkg
    for pkg in "$@"; do
        if is_installed "$pkg"; then
            ok "$pkg already installed"
        else
            missing+=("$pkg")
        fi
    done

    [ ${#missing[@]} -eq 0 ] && return 0

    for pkg in "${missing[@]}"; do
        info "Installing $pkg..."
    done

    prime_sudo
    local start=$SECONDS
    case "$manager" in
        # run_progress can only keep sudo out of its pty when sudo is the
        # leading command. yay calls sudo itself, deeper in, where the ticket
        # primed on our terminal doesn't apply -- so it stays on run_quiet,
        # which leaves sudo free to prompt on the real terminal via /dev/tty.
        pacman) run_progress sudo pacman -S --needed --noconfirm "${missing[@]}" ;;
        aur) run_quiet yay -S --needed --noconfirm "${missing[@]}" ;;
        *) die "Unknown package manager: $manager" ;;
    esac
    [ "${DRY_RUN}" = true ] && return 0
    ok "${#missing[@]} package(s) installed in $(fmt_duration "$((SECONDS - start))")"
}

install_packages() {
    require_cmd pacman
    _install_pkgs pacman "$@"
}

install_aur() {
    require_cmd yay
    _install_pkgs aur "$@"
}

# stow_config [--no-folding] <stow-package> [conflicting-path ...]
# Clears conflicting paths, then stows the package from $DOTFILES_DIR/stow.
# Existing symlinks (from a previous stow) are removed, and so are real files
# identical to the package's copy; anything else is moved to a timestamped
# .bak. --no-folding links files one by one instead of whole directories, for
# targets like ~/.config/systemd/user where programs add their own files that
# must not land in the repo.
stow_config() {
    require_cmd stow
    local stow_opts=()
    if [ "$1" = --no-folding ]; then
        stow_opts+=(--no-folding)
        shift
    fi
    local pkg="$1"
    shift
    local path backup packaged
    for path in "$@"; do
        packaged="$DOTFILES_DIR/stow/$pkg/${path#"$HOME"/}"
        if [ -L "$path" ]; then
            run_cmd rm -f "$path"
        elif [ -f "$path" ] && cmp -s "$path" "$packaged"; then
            run_cmd rm -f "$path"
        elif [ -e "$path" ]; then
            backup="$path.bak-$(date +%Y%m%d%H%M%S)"
            warn "Backing up existing $path -> $backup"
            run_cmd mv "$path" "$backup"
        fi
    done
    run_quiet stow "${stow_opts[@]}" -d "$DOTFILES_DIR/stow" -t "$HOME" "$pkg"
    ok "$pkg configured"
}

# write_root_file <dest> <body>
# Write a root-owned config file, skipping the write when it is already correct
# so re-runs don't churn mtimes (or force an initramfs rebuild). Compare with
# the same body before calling when the change needs a follow-up action.
write_root_file() {
    local dest="$1" body="$2" current=""

    [ -f "$dest" ] && current="$(cat "$dest")"
    if [ "$current" = "$body" ]; then
        ok "$(basename "$dest") already up to date"
        return 0
    fi

    if [ "${DRY_RUN}" = true ]; then
        info "[DRY-RUN] write $dest"
        return 0
    fi

    info "Writing $dest..."
    printf '%s\n' "$body" | sudo tee "$dest" >/dev/null
}

# --- machine profiles --------------------------------------------------------
# A profile (install-scripts/profiles/<name>.sh) says which hardware aspects a
# machine runs and holds its host-specific constants. The name also picks the
# Hyprland profile, config/<name>/.
PROFILES_DIR="$DOTFILES_DIR/install-scripts/profiles"
MACHINE_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/machine"

# load_profile -- choose this machine's profile on first use, then source it,
# setting MACHINE, MACHINE_ASPECTS and ETH_INTERFACE.
# shellcheck disable=SC2034 # the profile variables are read by the caller
load_profile() {
    local machine_lua="$DOTFILES_DIR/stow/hyprland/.config/hypr/machine.lua"
    local name="" choice options=()

    if [ -f "$MACHINE_STATE" ]; then
        name="$(cat "$MACHINE_STATE")"
    elif [ -f "$machine_lua" ]; then
        # Installed before profiles existed: keep the Hyprland profile that
        # was already chosen.
        name="$(grep -oP 'require\("config\.\K[^.]+' "$machine_lua" || true)"
        [ -n "$name" ] && info "Using machine profile '$name' from the existing machine.lua"
    fi

    if [ -z "$name" ]; then
        if [ "${DRY_RUN}" = true ]; then
            info "[DRY-RUN] select machine profile -> $MACHINE_STATE (assuming 'default')"
            name=default
        else
            for choice in "$PROFILES_DIR"/*.sh; do
                choice="$(basename "$choice")"
                options+=("${choice%.sh}")
            done
            info "Available machine profiles:"
            select name in "${options[@]}"; do
                [ -n "$name" ] && break
                warn "Invalid selection."
            done
        fi
    fi

    [ -f "$PROFILES_DIR/$name.sh" ] || die "Unknown machine profile '$name' (from $MACHINE_STATE)"

    if [ ! -f "$MACHINE_STATE" ] && [ "${DRY_RUN}" != true ]; then
        mkdir -p "$(dirname "$MACHINE_STATE")"
        printf '%s\n' "$name" >"$MACHINE_STATE"
    fi

    MACHINE="$name"
    MACHINE_ASPECTS=()
    ETH_INTERFACE=""
    source "$PROFILES_DIR/$name.sh"
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run] [--yes] [--verbose]

Options:
  --dry-run      Print commands without executing them
  --yes, -y      Assume yes for prompts (when supported)
  --verbose, -v  Show full package-manager output instead of summaries
  --help, -h     Show this help
EOF
}

# Parses the shared flags. An entrypoint that takes module names sets
# ACCEPT_POSITIONAL=true before calling it; the names land in POSITIONAL_ARGS
# and --all sets WANT_ALL. Anything else rejects them. Define `usage` after
# sourcing this file to replace the help text.
# shellcheck disable=SC2034 # WANT_ALL is read by the entrypoint
parse_args() {
    if [ "${PARSED_ARGS}" = true ]; then
        return 0
    fi

    local arg
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRY_RUN=true ;;
            --yes | -y) YES=true ;;
            --verbose | -v) VERBOSE=true ;;
            --help | -h)
                usage
                exit 0
                ;;
            --all)
                [ "${ACCEPT_POSITIONAL}" = true ] || die "Unknown argument: $arg"
                WANT_ALL=true
                ;;
            -*) die "Unknown argument: $arg" ;;
            *)
                [ "${ACCEPT_POSITIONAL}" = true ] || die "Unknown argument: $arg"
                POSITIONAL_ARGS+=("$arg")
                ;;
        esac
    done

    PARSED_ARGS=true
    export DRY_RUN YES VERBOSE PARSED_ARGS
}

# confirm <summary> -- ask before a multi-module run. --yes and --dry-run skip
# the question; answering anything but yes exits cleanly.
confirm() {
    local ans
    if [ "${YES}" = true ] || [ "${DRY_RUN}" = true ]; then
        return 0
    fi
    info "$1"
    read -rp "Proceed? [y/N] " ans
    case "$ans" in
        [yY] | [yY][eE][sS]) ;;
        *)
            warn "Aborted."
            exit 0
            ;;
    esac
}

# run_modules <stop|continue> <label> <resolver> <name>...
# Runs each name's script, found by calling `<resolver> <name>`, in its own
# bash. `stop` dies on the first failure, for lists where later entries build
# on earlier ones; `continue` reports the failure, carries on, and returns 1 at
# the end if anything failed.
run_modules() {
    local on_fail="$1" label="$2" resolver="$3"
    shift 3
    local name script failed=() ok_count=0

    for name in "$@"; do
        script="$("$resolver" "$name")"
        [ -f "$script" ] || die "$label '$name' not found: $script"
        info "${C_BOLD}>>> $label: $name${C_RESET}"
        if bash "$script"; then
            ok_count=$((ok_count + 1))
        elif [ "$on_fail" = stop ]; then
            die "$label '$name' failed"
        else
            failed+=("$name")
            warn "$name failed, continuing..."
        fi
    done

    if [ "$on_fail" = continue ]; then
        echo
        if [ ${#failed[@]} -gt 0 ]; then
            warn "$ok_count ok, ${#failed[@]} failed: ${failed[*]}"
            return 1
        fi
        ok "all $ok_count ${label}s completed"
    fi
}

if [ "${COMMON_AUTO_PARSE}" = true ]; then
    parse_args "$@"
fi

export DOTFILES_DIR REPO_URL C_RESET C_BOLD C_DIM C_BLUE C_GREEN C_YELLOW C_RED
export -f info ok warn die require_cmd is_wsl run_cmd run_quiet \
    run_remote_installer prime_sudo \
    fmt_duration _term_cols _progress_bar _progress_tail _progress_draw \
    _progress_abort run_progress \
    is_installed _install_pkgs install_packages install_aur \
    stow_config write_root_file usage parse_args confirm run_modules load_profile
