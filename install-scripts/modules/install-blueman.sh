#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    blueman \
    bluez \
    bluez-utils

info "Enabling bluetooth service..."
run_cmd sudo systemctl enable --now bluetooth.service
ok "bluetooth enabled"
