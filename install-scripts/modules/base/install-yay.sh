#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

require_cmd git

install_packages base-devel

if command -v yay >/dev/null 2>&1; then
    ok "yay already installed"
elif [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] build and install yay from the AUR"
else
    info "Installing yay from the AUR..."
    prime_sudo  # makepkg -si installs via sudo, hidden under run_quiet
    TEMP_DIR=$(mktemp -d)
    run_quiet git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    # Not run_progress: makepkg shells out to sudo for both the build deps and
    # the install, and sudo can't prompt from inside run_progress's pty.
    (cd "$TEMP_DIR/yay" && run_quiet makepkg -si --noconfirm)
    run_cmd rm -rf "$TEMP_DIR"
    ok "yay installed"
fi
