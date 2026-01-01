#!bin/bash

sudo pacman -S --needed --noconfirm \
    pipewire \
    wireplumber \
    pipewire-pulse \

yay -S --needed --noconfirm pipemixer
