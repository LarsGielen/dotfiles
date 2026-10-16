#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

UNIT_DIR="$HOME/.config/systemd/user"
SYNC_SCRIPT="$DOTFILES_DIR/utils/scripts/remote-sync-rclone.sh"
BISYNC_STATE_DIR="$HOME/.cache/rclone/bisync"

install_packages rclone

remote_exists() {
    rclone listremotes | grep -qx "$1:"
}

# Obsidian lives in an encrypted folder, so the crypt remote must be created
# with the password the existing data was encrypted with.
if ! remote_exists gdrive; then
    info "Creating the gdrive remote (a browser window opens for sign-in)..."
    run_cmd rclone config create gdrive drive scope=drive
fi

if ! remote_exists gdrive-crypt; then
    crypt_password="" crypt_salt=""
    if [ "${DRY_RUN}" != true ]; then
        read -rsp "Obsidian crypt password: " crypt_password
        echo
        read -rsp "Obsidian crypt salt (empty for none): " crypt_salt
        echo
    fi
    info "Creating the gdrive-crypt remote..."
    # rclone obscures password options itself when creating a remote.
    run_cmd rclone config create gdrive-crypt crypt \
        remote=gdrive:/Obsidian \
        password="$crypt_password" \
        ${crypt_salt:+password2="$crypt_salt"}
fi

# Before the timer is enabled, so a scheduled run can't beat the seeding resync.
if [ ! -d "$BISYNC_STATE_DIR" ]; then
    info "Running the first bisync with --resync..."
    run_cmd "$SYNC_SCRIPT" --resync
fi

# No folding: systemctl enable drops its *.wants links next to the units.
stow_config --no-folding systemd-user \
    "$UNIT_DIR/rclone-sync.service" \
    "$UNIT_DIR/rclone-sync.timer"

info "Enabling rclone-sync timer..."
run_cmd systemctl --user daemon-reload
run_cmd systemctl --user enable --now rclone-sync.timer
run_cmd systemctl --user enable rclone-sync.service

ok "rclone configured"
