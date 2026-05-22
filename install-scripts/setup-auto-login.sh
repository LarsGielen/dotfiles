#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

# Must run as root to write the systemd getty override.
[[ $EUID -eq 0 ]] || die "Please run as root (use sudo)"

read -rp "Enter the username you want to auto-login: " TARGET_USER

id "$TARGET_USER" &>/dev/null || die "User '$TARGET_USER' does not exist."

info "Configuring auto-login for: $TARGET_USER"
run_cmd mkdir -p /etc/systemd/system/getty@tty1.service.d/

if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] write getty@tty1 override.conf"
else
    cat <<EOF > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $TARGET_USER --noclear %I \$TERM
EOF
fi

ok "Auto-login configured on tty1."
