#!/bin/bash

echo "Installing ufw..."
sudo pacman -S --needed --noconfirm ufw

sudo systemctl enable --now ufw.service
sudo ufw enable