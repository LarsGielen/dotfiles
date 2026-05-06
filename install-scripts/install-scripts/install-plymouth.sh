#!/bin/bash

# Install Plymouth
sudo pacman -S --needed --noconfirm plymouth

# Enable NVIDIA Early KMS in mkinitcpio.conf
NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
if ! grep -q 'nvidia' /etc/mkinitcpio.conf; then
    sudo sed -i "s/^MODULES=(/MODULES=($NVIDIA_MODULES /" /etc/mkinitcpio.conf
fi

# Add plymouth to mkinitcpio.conf HOOKS
if ! grep -q '\bplymouth\b' /etc/mkinitcpio.conf; then
    sudo sed -i '/^HOOKS=/ s/udev/udev plymouth/' /etc/mkinitcpio.conf
fi

# Add kernel parameters for UKI
sudo mkdir -p /etc/cmdline.d
CMDLINE_FILE="/etc/cmdline.d/plymouth.conf"

if [ ! -f "$CMDLINE_FILE" ]; then
    echo "quiet splash" | sudo tee "$CMDLINE_FILE" > /dev/null
elif ! grep -q '\bsplash\b' "$CMDLINE_FILE"; then
    sudo sed -i '1s/$/ quiet splash/' "$CMDLINE_FILE"
fi

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

# Set the theme and automatically rebuild initramfs/UKI (-R flag)
if [ "$(plymouth-set-default-theme)" != "$THEME_NAME" ]; then
    sudo plymouth-set-default-theme -R "$THEME_NAME"
fi