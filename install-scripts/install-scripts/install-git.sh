#!/bin/bash

echo "Installing git..."
sudo pacman -S --needed --noconfirm \
    git \
    github-cli \
    git-lfs
