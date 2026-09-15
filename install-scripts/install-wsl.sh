#!/bin/bash
# Terminal-only install for an Arch WSL2 distro. It reuses the base aspects
# that are pure shell setup and leaves out everything that needs a GPU, a
# display or a login session -- drivers, audio, Hyprland, quickshell, kitty,
# keyd, snapper, ufw.
COMMON_AUTO_PARSE=false
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

MODULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/modules" && pwd)"

# Same contract as install-base.sh's BASE_MODULES: this list is the install
# order. prereqs comes first because a fresh rootfs has no package database
# yet, and theme comes before the aspects that stow the files it generates.
WSL_MODULES=(
    prereqs wslconf
    git yay stow
    theme
    shells starship yazi
    cli-tools
)

# An aspect is taken from modules/wsl/ when a WSL-specific version exists, and
# from the shared modules/base/ set otherwise.
aspect_path() {
    local override="$MODULES_DIR/wsl/install-$1.sh"
    if [ -f "$override" ]; then
        echo "$override"
    else
        echo "$MODULES_DIR/base/install-$1.sh"
    fi
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run] [--yes] [--verbose]

Install the terminal half of these dotfiles into an Arch WSL2 distro:
${WSL_MODULES[*]}

Optional extras stay with the normal entrypoint, e.g.
  ./install-all.sh python docker

Options:
  --dry-run      Print actions without executing them
  --yes, -y      Skip the confirmation prompt
  --verbose, -v  Show full package-manager output
  --help, -h     Show this help
EOF
}

parse_args "$@"

is_wsl || die "Not running inside WSL -- use install-all.sh on a real machine"

if [ "${YES}" != true ] && [ "${DRY_RUN}" != true ]; then
    info "About to install ${#WSL_MODULES[@]} aspect(s): ${WSL_MODULES[*]}"
    read -rp "Proceed? [y/N] " ans
    case "$ans" in
        [yY]|[yY][eE][sS]) ;;
        *) warn "Aborted."; exit 0 ;;
    esac
fi

prime_sudo

FAILED=()
OK_COUNT=0
for m in "${WSL_MODULES[@]}"; do
    script="$(aspect_path "$m")"
    [ -f "$script" ] || die "Aspect not found: $script"
    info "${C_BOLD}>>> wsl: $m${C_RESET}"
    if bash "$script"; then
        OK_COUNT=$((OK_COUNT + 1))
    else
        FAILED+=("$m")
        warn "$m failed, continuing..."
    fi
done

echo
if [ ${#FAILED[@]} -eq 0 ]; then
    ok "wsl terminal environment installed ($OK_COUNT aspects)"
else
    warn "$OK_COUNT ok, ${#FAILED[@]} failed: ${FAILED[*]}"
    exit 1
fi
