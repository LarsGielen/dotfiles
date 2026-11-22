#!/usr/bin/env bash
#
# setup-external-drive.sh
# -----------------------------------------------------------------------------
# Auto-mount a removable ext4 disk on a fixed path via an fstab systemd
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

FS_LABEL="external"
MOUNT_POINT="/mnt/external"
FSTAB_OPTIONS="noauto,nofail,x-systemd.automount,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s"
DRIVE_OWNER="${SUDO_USER:-}"

info() { printf '[*] %s\n' "$*"; }
ok() { printf '[+] %s\n' "$*"; }
warn() { printf '[!] %s\n' "$*"; }
die() {
    printf '[x] %s\n' "$*" >&2
    exit 1
}

[ "$EUID" -eq 0 ] || die "Run as root (sudo)."

install -d -m 755 "$MOUNT_POINT"

fstab_line="LABEL=${FS_LABEL} ${MOUNT_POINT} ext4 ${FSTAB_OPTIONS} 0 0"
if grep -qE "^[^#]*[[:space:]]${MOUNT_POINT}[[:space:]]" /etc/fstab; then
    info "fstab already has an entry for ${MOUNT_POINT} — leaving it alone."
else
    cp -a /etc/fstab "/etc/fstab.bak.$(date +%Y%m%d-%H%M%S)"
    printf '%s\n' "$fstab_line" >>/etc/fstab
    ok "Added fstab entry (backup saved)."
fi

systemctl daemon-reload
systemctl restart local-fs.target

# ext4 stores ownership on the filesystem, so fstab uid=/gid= cannot set it.
# Done once, non-recursively, while the disk is present; it persists on the disk.
if ! findmnt -n "$MOUNT_POINT" >/dev/null 2>&1 && [ -e "/dev/disk/by-label/${FS_LABEL}" ]; then
    ls "$MOUNT_POINT" >/dev/null # triggers the automount
fi
if mountpoint -q "$MOUNT_POINT"; then
    if [ -n "$DRIVE_OWNER" ]; then
        chown "${DRIVE_OWNER}:${DRIVE_OWNER}" "$MOUNT_POINT"
        ok "Gave ${DRIVE_OWNER} ownership of ${MOUNT_POINT}."
    fi
else
    warn "Disk not present — after first plugging it in, run:"
    warn "  sudo chown <user>: ${MOUNT_POINT}"
fi

ok "${MOUNT_POINT} will mount on first access whenever '${FS_LABEL}' is plugged in."
