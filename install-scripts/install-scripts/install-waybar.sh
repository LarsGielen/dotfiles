#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    waybar \
    ttf-jetbrains-mono-nerd

rm -rf ~/.config/waybar

stow -d ~/$REPO_NAME/stow -t ~ waybar

echo "waybar installed and configured successfully!"
