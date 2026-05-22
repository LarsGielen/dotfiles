#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_cmd git

install_packages base-devel

if command -v yay >/dev/null 2>&1; then
    ok "yay already installed"
else
    info "Installing yay from the AUR..."
    prime_sudo  # makepkg -si installs via sudo, hidden under run_quiet
    temp_dir=$(mktemp -d)
    run_quiet git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
    (cd "$temp_dir/yay" && run_quiet makepkg -si --noconfirm)
    run_cmd rm -rf "$temp_dir"
    ok "yay installed"
fi
