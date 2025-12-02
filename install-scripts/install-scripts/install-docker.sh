#!/bin/bash

echo "Installing docker..."
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    nvidia-container-toolkit \
    docker-buildx

sudo usermod -aG docker $USER             # Add user to docker group, enabling docker commands without sudo
sudo systemctl enable --now docker.socket # Enable Docker socket for on-demand use

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker.socket