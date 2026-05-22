#!/usr/bin/env bash
set -euo pipefail

# Shared helper functions for install scripts

: "${DRY_RUN:=false}"
: "${YES:=false}"
: "${VERBOSE:=false}"
: "${PARSED_ARGS:=false}"
: "${COMMON_AUTO_PARSE:=true}"
: "${DOTFILES_DIR:=$HOME/dotfiles}"
: "${REPO_URL:=https://github.com/LarsGielen/dotfiles}"

# --- Colors (only when writing to a terminal) ---
if [ -t 1 ]; then
    C_RESET=$'\033[0m'
    C_BOLD=$'\033[1m'
    C_BLUE=$'\033[34m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'
else
    C_RESET='' C_BOLD='' C_BLUE='' C_GREEN='' C_YELLOW='' C_RED=''
fi

info() { echo "${C_BLUE}::${C_RESET} $*"; }
ok()   { echo "${C_GREEN}✓${C_RESET} $*"; }
warn() { echo "${C_YELLOW}!${C_RESET} $*" >&2; }
die()  { echo "${C_RED}✗${C_RESET} $*" >&2; exit 1; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Required command '$1' not found"
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

# Cache sudo credentials up front so quiet/captured commands never block on a
# hidden password prompt. No-op under --dry-run.
prime_sudo() {
    [ "${DRY_RUN}" = true ] && return 0
    sudo -v
}

# True if a package is already installed (works for repo and AUR packages).
is_installed() {
    pacman -Qq "$1" >/dev/null 2>&1
}

# Shared install logic: report what's already present, install the rest quietly.
_install_pkgs() {
    local manager="$1"; shift
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
    case "$manager" in
        pacman) run_quiet sudo pacman -S --needed --noconfirm "${missing[@]}" ;;
        aur)    run_quiet yay -S --needed --noconfirm "${missing[@]}" ;;
        *)      die "Unknown package manager: $manager" ;;
    esac
}

# install_packages <pkg>...  -> install repo packages via pacman
install_packages() {
    require_cmd pacman
    _install_pkgs pacman "$@"
}

# install_aur <pkg>...  -> install AUR packages via yay
install_aur() {
    require_cmd yay
    _install_pkgs aur "$@"
}

# stow_config <stow-package> [conflicting-path ...]
# Clears conflicting paths, then stows the package from $DOTFILES_DIR/stow.
# Existing symlinks (from a previous stow) are removed; real files/dirs are
# moved to a timestamped .bak instead of being deleted.
stow_config() {
    require_cmd stow
    local pkg="$1"; shift
    local path backup
    for path in "$@"; do
        if [ -L "$path" ]; then
            run_cmd rm -f "$path"
        elif [ -e "$path" ]; then
            backup="$path.bak-$(date +%Y%m%d%H%M%S)"
            warn "Backing up existing $path -> $backup"
            run_cmd mv "$path" "$backup"
        fi
    done
    run_quiet stow -d "$DOTFILES_DIR/stow" -t "$HOME" "$pkg"
    ok "$pkg configured"
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

parse_args() {
    if [ "${PARSED_ARGS}" = true ]; then
        return 0
    fi

    for arg in "$@"; do
        case "$arg" in
            --dry-run)
                DRY_RUN=true
                ;;
            --yes|-y)
                YES=true
                ;;
            --verbose|-v)
                VERBOSE=true
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                die "Unknown argument: $arg"
                ;;
        esac
    done

    PARSED_ARGS=true
    export DRY_RUN YES VERBOSE PARSED_ARGS
}

if [ "${COMMON_AUTO_PARSE}" = true ]; then
    parse_args "$@"
fi

export DOTFILES_DIR REPO_URL C_RESET C_BOLD C_BLUE C_GREEN C_YELLOW C_RED
export -f info ok warn die require_cmd run_cmd run_quiet prime_sudo \
    is_installed _install_pkgs install_packages install_aur \
    stow_config usage parse_args
