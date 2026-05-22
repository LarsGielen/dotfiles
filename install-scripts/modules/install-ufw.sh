#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages ufw

info "Enabling firewall..."
run_cmd sudo systemctl enable --now ufw.service
run_cmd sudo ufw enable
ok "ufw enabled"
