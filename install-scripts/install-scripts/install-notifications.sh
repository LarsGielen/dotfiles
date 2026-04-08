#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    swaync \
    libnotify \
    ttf-jetbrains-mono-nerd

rm -rf ~/.config/swaync

stow -d ~/$REPO_NAME/stow -t ~ swaync

echo "swaync installed and configured successfully!"
