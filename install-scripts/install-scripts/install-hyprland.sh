#!/bin/bash

sudo pacman -S --needed --noconfirm \
    uwsm \
    libnewt \
    hyprland \
    egl-wayland \
    rofi-wayland \
    hyprpaper 

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

yay -S --needed --noconfirm \
    rose-pine-hyprcursor \
    rose-pine-cursor

sudo pacman -S --needed --noconfirm \
    kitty 

sudo pacman -S --needed --noconfirm \
    ntfs-3g

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

systemctl --user enable --now hyprpolkitagent.service
