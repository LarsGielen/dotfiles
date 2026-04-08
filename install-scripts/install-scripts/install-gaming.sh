#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    steam \
    gamemode \
    gamescope \
    mangohud

sudo usermod -aG gamemode "$USER"

rm -rf ~/.config/MangoHud

stow -d ~/$REPO_NAME/stow -t ~ MangoHud

echo "Gaming tools installed and configured successfully!"
