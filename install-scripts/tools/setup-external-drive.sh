#!/usr/bin/env bash
#
# setup-external-drive.sh
# -----------------------------------------------------------------------------
# Auto-mount a removable exFAT disk on a fixed path via an fstab systemd
# automount, without udisks2 or udiskie. The disk may be unplugged at any time.
#
# systemd creates the automount point at boot and mounts the disk on first
# access; 'nofail' plus a short device timeout means an absent disk never delays
# boot, and the idle timeout unmounts it so it is safe to unplug.
#
# Standalone on purpose, like setup-drive.sh: runnable as root on a machine
# without a checkout of this repo, so it does not source lib/common.sh.
#
# Usage:  sudo ./install-scripts/tools/setup-external-drive.sh
# -----------------------------------------------------------------------------

set -euo pipefail

FS_LABEL="External" # fstab LABEL= matching is case-sensitive
MOUNT_POINT="/mnt/external"
MOUNT_OPTIONS="noauto,nofail,x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s"
DRIVE_OWNER="${SUDO_USER:-}"

info() { printf '[*] %s\n' "$*"; }
ok() { printf '[+] %s\n' "$*"; }
die() {
    printf '[x] %s\n' "$*" >&2
    exit 1
}

[ "$EUID" -eq 0 ] || die "Run as root (sudo)."
[ -n "$DRIVE_OWNER" ] || die "No \$SUDO_USER to own the files; run via sudo."

# exFAT cannot store ownership, so the whole mount is owned by this user.
owner_options="uid=$(id -u "$DRIVE_OWNER"),gid=$(id -g "$DRIVE_OWNER")"
fstab_line="LABEL=${FS_LABEL} ${MOUNT_POINT} exfat ${MOUNT_OPTIONS},${owner_options} 0 0"
existing_pattern="^[^#]*[[:space:]]${MOUNT_POINT}[[:space:]]"

# A live automount makes the directory check below try to mount the disk, which
# fails while the old fstab entry (or a missing disk) is still in effect.
automount_unit=$(systemd-escape --path --suffix=automount "$MOUNT_POINT")
if systemctl is-active --quiet "$automount_unit"; then
    systemctl stop "$automount_unit"
fi

install -d -m 755 "$MOUNT_POINT"

if grep -qxF "$fstab_line" /etc/fstab; then
    info "fstab already has this entry for ${MOUNT_POINT}."
else
    cp -a /etc/fstab "/etc/fstab.bak.$(date +%Y%m%d-%H%M%S)"
    sed -i -E "\\|${existing_pattern}|d" /etc/fstab
    printf '%s\n' "$fstab_line" >>/etc/fstab
    ok "Wrote fstab entry (backup saved)."
fi

systemctl daemon-reload
systemctl restart local-fs.target

ok "${MOUNT_POINT} will mount on first access whenever '${FS_LABEL}' is plugged in."
