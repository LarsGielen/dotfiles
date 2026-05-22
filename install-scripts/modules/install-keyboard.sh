#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    stow \
    keyd

stow_config keyd ~/.config/keyd

USER_CONFIG_FILE="$HOME/.config/keyd/default.conf"
info "Linking keyd config into /etc/keyd..."
run_cmd sudo mkdir -p /etc/keyd
run_cmd sudo ln -sf "$USER_CONFIG_FILE" /etc/keyd/default.conf

info "Enabling keyd service..."
run_cmd sudo systemctl enable --now keyd
ok "keyd enabled"
