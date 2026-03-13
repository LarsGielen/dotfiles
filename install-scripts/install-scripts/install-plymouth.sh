#!/bin/bash

# Install Plymouth
sudo pacman -S --needed --noconfirm plymouth

# Add plymouth to mkinitcpio.conf HOOKS
if ! grep -q '\bplymouth\b' /etc/mkinitcpio.conf; then
    sudo sed -i '/^HOOKS=/ s/udev/udev plymouth/' /etc/mkinitcpio.conf
fi

# Add kernel parameters to systemd-boot entry
for entry in /boot/loader/entries/*.conf; do
    if [ -f "$entry" ] && grep -q "^options" "$entry"; then
        if ! grep -q '\bsplash\b' "$entry"; then
            sudo sed -i 's/^options .*/& quiet splash/' "$entry"
        fi
    fi
done

# Install and apply custom theme
THEME_NAME="custom_theme"
THEME_SRC="$HOME/dotfiles/stow/plymouth/$THEME_NAME"
THEME_DEST="/usr/share/plymouth/themes/$THEME_NAME"

if [ -d "$THEME_SRC" ]; then
    sudo cp -rT "$THEME_SRC" "$THEME_DEST"
else
    echo "Error: Theme source '$THEME_SRC' not found."
    exit 1
fi

if [ "$(plymouth-set-default-theme)" != "$THEME_NAME" ]; then
    sudo plymouth-set-default-theme -R "$THEME_NAME"
fi

# Set the theme and automatically rebuild initramfs (-R flag)
if [ "$(plymouth-set-default-theme)" != "$THEME_NAME" ]; then
    sudo plymouth-set-default-theme -R "$THEME_NAME"
fi