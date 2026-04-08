#!/bin/bash

REPO_NAME="dotfiles"

# Install Hyprland
sudo pacman -S --needed --noconfirm \
    stow \
    uwsm \
    libnewt \
    hyprland

# Install Hyprland dependencies
sudo pacman -S --needed --noconfirm \
    hyprpolkitagent \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland \
    xorg-xhost
systemctl --user enable --now hyprpolkitagent.service

# Install cursor themes
yay -S --needed --noconfirm \
    rose-pine-hyprcursor \
    rose-pine-cursor

# Install Hyprland utilities
sudo pacman -S --needed --noconfirm \
    hyprpaper \
    hyprsunset
yay -S --needed --noconfirm hyprshot

# Configure machine-specific Hyprland config
MACHINE_CONF="$HOME/$REPO_NAME/stow/hyprland/.config/hypr/machine.conf"
if [ ! -f "$MACHINE_CONF" ]; then
    HYPR_CONFIG_DIR="$HOME/$REPO_NAME/stow/hyprland/.config/hypr/config"
    mapfile -t OPTIONS < <(ls -1 "$HYPR_CONFIG_DIR")
    echo "Available Hyprland config options:"
    select CHOSEN_OPTION in "${OPTIONS[@]}"; do
        if [[ -n "$CHOSEN_OPTION" ]]; then
            break
        else
            echo "Invalid selection."
        fi
    done
    mkdir -p "$(dirname "$MACHINE_CONF")"
    echo "source = ~/.config/hypr/config/$CHOSEN_OPTION/_hyprland-$CHOSEN_OPTION.conf" >> "$MACHINE_CONF"
fi

rm -rf ~/.config/hypr
rm -rf ~/.config/uwsm

stow -d ~/$REPO_NAME/stow -t ~ hyprland
stow -d ~/$REPO_NAME/stow -t ~ uwsm

echo "Hyprland installed and configured successfully!"
