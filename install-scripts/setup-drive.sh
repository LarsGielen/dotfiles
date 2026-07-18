#!/usr/bin/env bash
#
# setup-encrypted-drive.sh
# -----------------------------------------------------------------------------
# Set up a secondary drive with LUKS2 encryption, a root-stored keyfile for
# automatic unlock at boot, and an auto-mount via /etc/fstab.
#
# Security model (chained unlock):
#   passphrase unlocks encrypted ROOT in initramfs  ->  root mounted
#   ->  systemd reads /etc/crypttab  ->  keyfile on root unlocks this drive
#   ->  /etc/fstab mounts it.
# The keyfile is only as exposed as your already-encrypted root, and it never
# leaves the machine, so this script is safe to version-control as-is.
#
# This is for a SECONDARY (data) drive only. It does NOT touch mkinitcpio /
# initramfs — that is only needed when the encrypted drive holds root.
#
# SAFETY: luksFormat DESTROYS all data on TARGET_DEVICE. The script refuses to
# run against mounted devices or the disk backing '/', shows you the layout,
# and requires you to type the device name to confirm. It is idempotent: it
# will not reformat an existing LUKS container or wipe an existing filesystem.
#
# Usage:  sudo ./setup-encrypted-drive.sh
# -----------------------------------------------------------------------------

set -euo pipefail

### ==== Configuration — edit these ==========================================
TARGET_DEVICE="/dev/nvme1n1"                       # whole disk to encrypt
MAPPER_NAME="cryptdata"                            # /dev/mapper/<name>
MOUNT_POINT="/mnt/data"                            # where it gets mounted
FILESYSTEM="ext4"                                  # ext4 | btrfs | xfs ...
KEYFILE="/etc/cryptsetup-keys.d/${MAPPER_NAME}.key"  # MUST live outside the repo
LUKS_LABEL="${MAPPER_NAME}"                         # LUKS2 container label
FS_LABEL="DATA"                                    # filesystem label
DRIVE_OWNER="${SUDO_USER:-}"                        # user to own the mount (auto from sudo)
ENABLE_TRIM=true                                   # allow periodic fstrim (SSD)
### =========================================================================

# --- pretty logging -------------------------------------------------------
c_red=$'\e[31m'; c_grn=$'\e[32m'; c_ylw=$'\e[33m'; c_blu=$'\e[34m'; c_rst=$'\e[0m'
log()  { printf '%s[*]%s %s\n'  "$c_blu" "$c_rst" "$*"; }
ok()   { printf '%s[+]%s %s\n'  "$c_grn" "$c_rst" "$*"; }
warn() { printf '%s[!]%s %s\n'  "$c_ylw" "$c_rst" "$*"; }
die()  { printf '%s[x]%s %s\n'  "$c_red" "$c_rst" "$*" >&2; exit 1; }

# --- preflight ------------------------------------------------------------
require_root() {
    [[ $EUID -eq 0 ]] || die "Run as root (sudo)."
}

check_deps() {
    local missing=()
    for cmd in cryptsetup blkid lsblk findmnt "mkfs.${FILESYSTEM}"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    ((${#missing[@]} == 0)) || die "Missing commands: ${missing[*]}"
}

# Refuse if the keyfile would ever end up in a repo / user home.
guard_keyfile_location() {
    case "$KEYFILE" in
        /etc/*) : ;;  # good — outside any working tree
        *) die "KEYFILE must live under /etc (never in a git repo). Got: $KEYFILE" ;;
    esac
}

validate_device() {
    [[ -b "$TARGET_DEVICE" ]] || die "Not a block device: $TARGET_DEVICE"

    # Never touch the disk that backs '/'.
    local root_src root_disk
    root_src=$(findmnt -n -o SOURCE / || true)
    root_disk=$(lsblk -no PKNAME "$root_src" 2>/dev/null | head -n1 || true)
    if [[ -n "$root_disk" && "/dev/$root_disk" == "$TARGET_DEVICE" ]]; then
        die "$TARGET_DEVICE hosts your root filesystem. Refusing."
    fi

    # Refuse if the device or any child is currently mounted.
    local mounted
    mounted=$(lsblk -nro MOUNTPOINT "$TARGET_DEVICE" | sed '/^$/d' || true)
    if [[ -n "$mounted" ]]; then
        die "$TARGET_DEVICE has mounted filesystems:"$'\n'"$mounted"
    fi
}

confirm_destruction() {
    if cryptsetup isLuks "$TARGET_DEVICE" 2>/dev/null; then
        warn "$TARGET_DEVICE is already a LUKS container — it will be reused, not reformatted."
        return 0
    fi

    echo
    warn "About to ENCRYPT and ERASE this device:"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MODEL "$TARGET_DEVICE"
    echo
    warn "ALL DATA on $TARGET_DEVICE will be permanently destroyed."
    read -rp "Type the device name (${TARGET_DEVICE}) to continue: " reply
    [[ "$reply" == "$TARGET_DEVICE" ]] || die "Confirmation mismatch. Aborting."
}

# --- steps ----------------------------------------------------------------
create_keyfile() {
    install -d -m 700 -o root -g root "$(dirname "$KEYFILE")"
    if [[ -f "$KEYFILE" ]]; then
        log "Keyfile already exists: $KEYFILE"
    else
        log "Generating random keyfile: $KEYFILE"
        dd if=/dev/urandom of="$KEYFILE" bs=512 count=8 status=none
    fi
    chmod 600 "$KEYFILE"; chown root:root "$KEYFILE"
}

luks_format_and_key() {
    if cryptsetup isLuks "$TARGET_DEVICE" 2>/dev/null; then
        log "Existing LUKS container detected — skipping luksFormat."
    else
        log "Formatting $TARGET_DEVICE as LUKS2."
        warn "You'll now set a RECOVERY PASSPHRASE (your manual fallback key)."
        cryptsetup luksFormat --type luks2 --label "$LUKS_LABEL" "$TARGET_DEVICE"
    fi

    # Add the keyfile as an unlock key only if it isn't already valid.
    if cryptsetup open --test-passphrase --key-file "$KEYFILE" \
            "$TARGET_DEVICE" >/dev/null 2>&1; then
        log "Keyfile is already a valid unlock key — skipping luksAddKey."
    else
        log "Adding keyfile as an unlock key (enter an existing passphrase)."
        cryptsetup luksAddKey "$TARGET_DEVICE" "$KEYFILE"
    fi
}

open_and_format() {
    if [[ ! -e "/dev/mapper/${MAPPER_NAME}" ]]; then
        log "Opening container as /dev/mapper/${MAPPER_NAME}."
        cryptsetup open --key-file "$KEYFILE" "$TARGET_DEVICE" "$MAPPER_NAME"
    fi

    local existing_fs
    existing_fs=$(blkid -s TYPE -o value "/dev/mapper/${MAPPER_NAME}" 2>/dev/null || true)
    if [[ -n "$existing_fs" ]]; then
        log "Filesystem already present (${existing_fs}) — skipping mkfs."
    else
        log "Creating ${FILESYSTEM} filesystem."
        case "$FILESYSTEM" in
            ext4)      mkfs.ext4  -L "$FS_LABEL" "/dev/mapper/${MAPPER_NAME}" ;;
            xfs)       mkfs.xfs   -L "$FS_LABEL" "/dev/mapper/${MAPPER_NAME}" ;;
            btrfs)     mkfs.btrfs -L "$FS_LABEL" "/dev/mapper/${MAPPER_NAME}" ;;
            *)         "mkfs.${FILESYSTEM}" "/dev/mapper/${MAPPER_NAME}" ;;
        esac
    fi
}

# Append a line to a config file only if a matching entry isn't already there.
append_once() {
    local file="$1" match_regex="$2" line="$3"
    touch "$file"
    if grep -qE "$match_regex" "$file"; then
        log "Entry already present in $file — leaving it alone."
    else
        cp -a "$file" "${file}.bak.$(date +%Y%m%d-%H%M%S)"
        printf '%s\n' "$line" >> "$file"
        ok "Added entry to $file (backup saved)."
    fi
}

configure_crypttab() {
    local luks_uuid crypt_opts
    luks_uuid=$(cryptsetup luksUUID "$TARGET_DEVICE")
    crypt_opts="luks"
    [[ "$ENABLE_TRIM" == true ]] && crypt_opts="luks,discard"
    append_once /etc/crypttab \
        "^[[:space:]]*${MAPPER_NAME}[[:space:]]" \
        "${MAPPER_NAME} UUID=${luks_uuid} ${KEYFILE} ${crypt_opts}"
}

configure_fstab() {
    install -d -m 755 "$MOUNT_POINT"
    # 'nofail' so a missing drive never blocks boot; device-timeout keeps it snappy.
    append_once /etc/fstab \
        "[[:space:]]${MOUNT_POINT}[[:space:]]" \
        "/dev/mapper/${MAPPER_NAME} ${MOUNT_POINT} ${FILESYSTEM} defaults,nofail,x-systemd.device-timeout=10s 0 2"
}

# Give the user write access. ext4/btrfs/xfs store ownership on the filesystem
# itself (fstab uid=/gid= only work on vfat/exfat/ntfs), so we chown the mount
# root once while mounted — it persists across reboots. Non-recursive on purpose:
# we never mass-chown data that may already live on a reused drive.
set_ownership() {
    local owner="$DRIVE_OWNER"
    if [[ -z "$owner" ]]; then
        warn "DRIVE_OWNER unset and no \$SUDO_USER — leaving root ownership."
        warn "  Fix manually: sudo chown <user>: ${MOUNT_POINT}"
        return 0
    fi
    if ! id "$owner" >/dev/null 2>&1; then
        warn "User '$owner' not found — skipping chown."
        return 0
    fi
    if ! mountpoint -q "$MOUNT_POINT"; then
        warn "Not mounted yet — set ownership after it mounts:"
        warn "  sudo chown ${owner}: ${MOUNT_POINT}"
        return 0
    fi
    log "Granting ownership of ${MOUNT_POINT} to ${owner}."
    chown "${owner}:${owner}" "$MOUNT_POINT"
    chmod 755 "$MOUNT_POINT"
    ok "${owner} can now read/write ${MOUNT_POINT}."
}

finalize() {
    log "Reloading systemd and mounting."
    systemctl daemon-reload
    mount "$MOUNT_POINT" 2>/dev/null || warn "Mount deferred — will mount on next boot."
    set_ownership
    if [[ "$ENABLE_TRIM" == true ]]; then
        systemctl enable --now fstrim.timer >/dev/null 2>&1 || true
    fi
    echo
    ok "Done. Current state:"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT "$TARGET_DEVICE"
    echo
    ok "It will auto-unlock and auto-mount at ${MOUNT_POINT} on every boot."
    warn "Keep your recovery passphrase safe. Never commit ${KEYFILE}."
}

main() {
    require_root
    check_deps
    guard_keyfile_location
    validate_device
    confirm_destruction
    create_keyfile
    luks_format_and_key
    open_and_format
    configure_crypttab
    configure_fstab
    finalize
}

main "$@"