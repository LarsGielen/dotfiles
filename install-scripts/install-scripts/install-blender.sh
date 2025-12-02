#!/bin/bash

echo "Installing blender..."
sudo pacman -S --needed --noconfirm \
    blender \
    cuda
