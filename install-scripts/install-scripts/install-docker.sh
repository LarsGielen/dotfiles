#!/bin/bash

# Install dependencies
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    nvidia-container-toolkit \
    docker-buildx

# Add user to docker group
sudo usermod -aG docker "$USER"

# Create a systemd override to prevent Docker from waiting for a full network-online status.
# This fixes the hang caused by disconnected Wi-Fi adapters.
sudo mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/fast-start.conf
[Unit]
Wants=
After=
After=network.target
EOF

# Configure NVIDIA runtime
sudo nvidia-ctk runtime configure --runtime=docker

# Reload systemd to apply the override and enable Docker
sudo systemctl daemon-reload
sudo systemctl restart docker