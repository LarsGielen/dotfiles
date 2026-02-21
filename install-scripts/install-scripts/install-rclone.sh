#!/bin/bash

# 1. Install Rclone
sudo pacman -S --noconfirm rclone

# 2. Create systemd user directory
SYNC_INTERVAL="1h"
SERVICE_FILE="$HOME/.config/systemd/user/rclone-sync.service"
TIMER_FILE="$HOME/.config/systemd/user/rclone-sync.timer"

mkdir -p "$(dirname "$SERVICE_FILE")"

# 1. Create Service File (defines the 'What')
if [ ! -f "$SERVICE_FILE" ]; then
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
    echo "Created service file: $SERVICE_FILE"
else
    echo "Service file already exists. Skipping."
fi

# 2. Create Timer File (defines the 'When')
if [ ! -f "$TIMER_FILE" ]; then
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
    echo "Created timer file: $TIMER_FILE"
else
    echo "Timer file already exists. Skipping."
fi

# 5. Reload and Enable
systemctl --user daemon-reload
systemctl --user enable --now rclone-sync.timer
systemctl --user enable rclone-sync.service

echo "Setup complete. Remember to run 'rclone config' to create your remote before the first sync. and perform a resync the first time"