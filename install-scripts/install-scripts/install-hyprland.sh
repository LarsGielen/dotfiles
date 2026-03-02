#!/bin/bash

# Install Hyprland
sudo pacman -S --needed --noconfirm \
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

