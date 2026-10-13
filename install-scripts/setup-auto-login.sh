#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

# Run as the normal user: under sudo $HOME is /root, so common.sh can't find
# ~/dotfiles. Only the override write needs root.
[ "$EUID" -ne 0 ] || die "Run as your normal user, not with sudo; it asks for sudo itself"

OVERRIDE_DIR="/etc/systemd/system/getty@tty1.service.d"

if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] prompt for a username and write $OVERRIDE_DIR/override.conf"
    exit 0
fi

read -rp "Enter the username you want to auto-login [$USER]: " TARGET_USER
TARGET_USER="${TARGET_USER:-$USER}"
id "$TARGET_USER" >/dev/null 2>&1 || die "User '$TARGET_USER' does not exist."

# write_root_file runs sudo tee inside a pipe, so credentials must already
# be cached.
prime_sudo

info "Configuring auto-login for: $TARGET_USER"
sudo mkdir -p "$OVERRIDE_DIR"
write_root_file "$OVERRIDE_DIR/override.conf" "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $TARGET_USER --noclear %I \$TERM"

ok "auto-login configured on tty1"
