#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    kitty \
    ttf-jetbrains-mono-nerd

rm -rf ~/.config/kitty

stow -d ~/$REPO_NAME/stow -t ~ kitty

echo "kitty installed and configured successfully!"
