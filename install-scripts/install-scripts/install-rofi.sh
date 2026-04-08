#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    rofi-wayland \
    ttf-roboto

rm -rf ~/.config/rofi

stow -d ~/$REPO_NAME/stow -t ~ rofi

echo "rofi installed and configured successfully!"
