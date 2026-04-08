#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    starship \
    ttf-jetbrains-mono-nerd

rm -rf ~/.config/starship.toml

stow -d ~/$REPO_NAME/stow -t ~ starship

echo "starship installed and configured successfully!"
