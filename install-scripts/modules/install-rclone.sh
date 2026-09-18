#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

UNIT_DIR="$HOME/.config/systemd/user"

install_packages rclone

# No folding: systemctl enable drops its *.wants links next to the units.
stow_config --no-folding systemd-user \
    "$UNIT_DIR/rclone-sync.service" \
    "$UNIT_DIR/rclone-sync.timer"

info "Enabling rclone-sync timer..."
run_cmd systemctl --user daemon-reload
run_cmd systemctl --user enable --now rclone-sync.timer
run_cmd systemctl --user enable rclone-sync.service

ok "rclone configured"
warn "Run 'rclone config' to create your remote before the first sync, and resync the first time."
