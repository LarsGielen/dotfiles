#!/bin/bash

USER_CONFIG_DIR="$HOME/.config/keyd"
USER_CONFIG_FILE="$USER_CONFIG_DIR/default.conf"

sudo pacman -S --noconfirm --needed \
    keyd

sudo mkdir -p /etc/keyd
sudo ln -sf "$USER_CONFIG_FILE" /etc/keyd/default.conf

sudo systemctl enable --now keyd