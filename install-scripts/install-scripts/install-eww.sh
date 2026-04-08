#!/bin/bash

REPO_NAME="dotfiles"

yay -S --needed --noconfirm \
    eww

sudo pacman -S --needed --noconfirm \
    stow \
    ttf-jetbrains-mono-nerd

rm -rf ~/.config/eww

stow -d ~/$REPO_NAME/stow -t ~ eww

echo "eww installed and configured successfully!"
