#!/bin/bash

echo "Installing Hyprland..."
sudo pacman -S --needed --noconfirm \
    uwsm \
    libnewt \
    hyprland \
    egl-wayland \
    rofi-wayland \
    hyprpaper 

echo "Installing fonts..."
sudo pacman -S --needed --noconfirm \
    ttf-fira-sans \
    ttf-font-awesome \
    ttf-roboto \
    ttf-dejavu \
    ttf-liberation \
    noto-fonts-emoji \
    ttf-jetbrains-mono-nerd \
    ttf-jetbrains-mono \
    noto-fonts-cjk

echo "Installing cursor themes..."
yay -S --needed --noconfirm \
    rose-pine-hyprcursor \
    rose-pine-cursor

echo "Installing terminal applications..."
sudo pacman -S --needed --noconfirm \
    kitty 

echo "Installing file system support..."
sudo pacman -S --needed --noconfirm \
    ntfs-3g

echo "Installing basic control applications..."
sudo pacman -S --needed --noconfirm \
    hyprpolkitagent \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland \
    xorg-xhost \
    nvidia-settings

yay -S --needed --noconfirm hyprshot

echo "Enabling and starting services..."
systemctl --user enable --now hyprpolkitagent.service
