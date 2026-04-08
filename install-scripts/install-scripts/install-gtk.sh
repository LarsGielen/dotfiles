#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    gtk3

rm -rf ~/.config/gtk-3.0

stow -d ~/$REPO_NAME/stow -t ~ gtk

echo "gtk installed and configured successfully!"
