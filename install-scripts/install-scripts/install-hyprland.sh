#!/bin/bash

sudo pacman -S --needed --noconfirm \
    uwsm \
    libnewt \
    hyprland \
    egl-wayland \
    hyprpaper 

yay -S --needed --noconfirm \
    rose-pine-hyprcursor \
    rose-pine-cursor

sudo pacman -S --needed --noconfirm \
    hyprpolkitagent \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland \
    xorg-xhost 

yay -S --needed --noconfirm hyprshot

systemctl --user enable --now hyprpolkitagent.service
