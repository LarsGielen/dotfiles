#!/bin/bash

# yazi - Terminal file manager
# ffmpeg - For video thumbnails
# 7zip - For archive extraction
# zoxide - For historical file navigation
# wl-clipboard - For clipboard integration (Wayland)

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    yazi \
    ffmpeg \
    7zip \
    zoxide \
    wl-clipboard

rm -rf ~/.config/yazi

stow -d ~/$REPO_NAME/stow -t ~ yazi

echo "Yazi installed and configured successfully!"
