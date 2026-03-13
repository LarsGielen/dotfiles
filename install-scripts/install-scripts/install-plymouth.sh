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

# Install and apply custom theme using stow
THEME_NAME="custom_theme"
STOW_DIR="$HOME/dotfiles/stow/plymouth"

# Ensure stow is installed
sudo pacman -S --needed --noconfirm stow

# Create symlinks. 
# This assumes $STOW_DIR/$THEME_NAME contains the actual theme folder.
# Example: ./stow_packages/my_theme/my_theme.plymouth
sudo stow -t /usr/share/plymouth/themes -d "$STOW_DIR" "$THEME_NAME"

# Set the theme and automatically rebuild initramfs (-R flag)
if [ "$(plymouth-set-default-theme)" != "$THEME_NAME" ]; then
    sudo plymouth-set-default-theme -R "$THEME_NAME"
fi