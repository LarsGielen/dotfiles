#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    bash

rm -rf ~/.bashrc
rm -rf ~/.bash_profile

stow -d ~/$REPO_NAME/stow -t ~ bash

echo "bash installed and configured successfully!"
