#!/bin/bash
    
# yazi - Terminal file manager
# ffmpeg - For clipboard integration
# 7zip - For video thumbnails
# zoxide - For historical file navigation
# wl-clipboard - For archive extraction

echo "Installing Yazi..."
sudo pacman -S --needed --noconfirm \
    yazi \
    ffmpeg \
    7zip \
    zoxide \
    wl-clipboard
