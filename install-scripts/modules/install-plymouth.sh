#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages plymouth

if grep -q '\bplymouth\b' /etc/mkinitcpio.conf; then
    ok "plymouth hook already in mkinitcpio.conf"
else
    info "Adding plymouth hook to mkinitcpio.conf..."
    run_cmd sudo sed -i '/^HOOKS=/ s/udev/udev plymouth/' /etc/mkinitcpio.conf
fi

# A UKI takes its kernel parameters from /etc/cmdline.d, not the bootloader.
run_cmd sudo mkdir -p /etc/cmdline.d
CMDLINE_FILE="/etc/cmdline.d/plymouth.conf"

if [ ! -f "$CMDLINE_FILE" ]; then
    info "Creating kernel cmdline $CMDLINE_FILE..."
    if [ "${DRY_RUN}" = true ]; then
        info "[DRY-RUN] write 'quiet splash' to $CMDLINE_FILE"
    else
        echo "quiet splash" | sudo tee "$CMDLINE_FILE" >/dev/null
    fi
elif ! grep -q '\bsplash\b' "$CMDLINE_FILE"; then
    info "Adding 'quiet splash' to $CMDLINE_FILE..."
    run_cmd sudo sed -i '1s/$/ quiet splash/' "$CMDLINE_FILE"
else
    ok "kernel cmdline already carries 'splash'"
fi

THEME_NAME="custom_theme"
THEME_SRC="$DOTFILES_DIR/stow/plymouth/$THEME_NAME"
THEME_DEST="/usr/share/plymouth/themes/$THEME_NAME"

if [ -d "$THEME_SRC" ]; then
    info "Installing plymouth theme '$THEME_NAME'..."
    run_cmd sudo cp -rT "$THEME_SRC" "$THEME_DEST"
else
    die "Theme source '$THEME_SRC' not found."
fi

if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] set default theme to '$THEME_NAME' and rebuild the initramfs"
elif [ "$(plymouth-set-default-theme)" != "$THEME_NAME" ]; then
    info "Setting default theme and rebuilding initramfs..."
    run_quiet sudo plymouth-set-default-theme -R "$THEME_NAME"
fi
ok "plymouth configured"
