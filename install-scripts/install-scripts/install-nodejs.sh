#!/bin/bash

echo "Installing nodejs..."
sudo pacman -S --needed --noconfirm \
    nodejs \
    npm 