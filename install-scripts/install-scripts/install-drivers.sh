#!/bin/bash
echo "Installing drivers..."

sudo pacman -S --needed --noconfirm \
    amd-ucode \
    nvidia-open \
    nvidia-utils \
    lib32-nvidia-utils