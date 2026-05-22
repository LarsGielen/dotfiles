#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages rclone

SYNC_INTERVAL="1h"
SERVICE_FILE="$HOME/.config/systemd/user/rclone-sync.service"
TIMER_FILE="$HOME/.config/systemd/user/rclone-sync.timer"

run_cmd mkdir -p "$(dirname "$SERVICE_FILE")"

# Service file (defines the 'What')
if [ -f "$SERVICE_FILE" ]; then
    ok "rclone-sync.service already exists"
elif [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] create $SERVICE_FILE"
else
    info "Creating $SERVICE_FILE..."
    cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Sync remote folders using rclone
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=%h/dotfiles/utils/scripts/remote-sync-rclone.sh
ExecStop=%h/dotfiles/utils/scripts/remote-sync-rclone.sh

[Install]
WantedBy=default.target
EOF
fi

# Timer file (defines the 'When')
if [ -f "$TIMER_FILE" ]; then
    ok "rclone-sync.timer already exists"
elif [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] create $TIMER_FILE"
else
    info "Creating $TIMER_FILE..."
    cat <<EOF > "$TIMER_FILE"
[Unit]
Description=Scheduled sync for remote drives

[Timer]
# Initial delay after boot
OnBootSec=1min
# Frequency of sync while running
OnUnitActiveSec=$SYNC_INTERVAL
# Run immediately if a scheduled sync was missed while PC was off
Persistent=true

[Install]
WantedBy=timers.target
EOF
fi

info "Enabling rclone-sync timer..."
run_cmd systemctl --user daemon-reload
run_cmd systemctl --user enable --now rclone-sync.timer
run_cmd systemctl --user enable rclone-sync.service

ok "rclone configured"
warn "Run 'rclone config' to create your remote before the first sync, and resync the first time."
