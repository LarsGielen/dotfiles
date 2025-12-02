#!/bin/bash

echo "Installing steam..."
sudo pacman -S --needed --noconfirm \
    steam \
    gamemode \
    gamescope

sudo usermod -aG gamemode $USER