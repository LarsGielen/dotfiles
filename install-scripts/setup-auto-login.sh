#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

# Must run as root to write the systemd getty override.
[ "$EUID" -eq 0 ] || die "Please run as root (use sudo)"

OVERRIDE_DIR="/etc/systemd/system/getty@tty1.service.d"

if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] prompt for a username and write $OVERRIDE_DIR/override.conf"
    exit 0
fi

read -rp "Enter the username you want to auto-login: " TARGET_USER
id "$TARGET_USER" >/dev/null 2>&1 || die "User '$TARGET_USER' does not exist."

info "Configuring auto-login for: $TARGET_USER"
mkdir -p "$OVERRIDE_DIR"
cat >"$OVERRIDE_DIR/override.conf" <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $TARGET_USER --noclear %I \$TERM
EOF

ok "auto-login configured on tty1"
