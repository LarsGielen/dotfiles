#!/bin/bash

REPO_NAME="dotfiles"

sudo pacman -S --noconfirm --needed \
    stow \
    keyd

rm -rf ~/.config/keyd

stow -d ~/$REPO_NAME/stow -t ~ keyd

USER_CONFIG_FILE="$HOME/.config/keyd/default.conf"
sudo mkdir -p /etc/keyd
sudo ln -sf "$USER_CONFIG_FILE" /etc/keyd/default.conf

sudo systemctl enable --now keyd
echo "keyd installed and configured successfully!"
