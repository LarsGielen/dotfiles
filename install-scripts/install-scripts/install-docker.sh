#!/bin/bash

# Install dependencies
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    nvidia-container-toolkit \
    docker-buildx

# Add user to docker group
sudo usermod -aG docker "$USER"

# Configure NVIDIA runtime
sudo nvidia-ctk runtime configure --runtime=docker

# Fix slow Docker startup: systemd-networkd-wait-online waits for all managed
# interfaces, including wifi (wlp9s0) which has no carrier. Override it to only
# wait for ethernet.
sudo mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
sudo tee /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --interface=eno1
EOF

# Mark wifi as unmanaged so it doesn't appear as a stray 'configuring' interface
sudo tee /etc/systemd/network/99-ignore-wifi.network > /dev/null <<EOF
[Match]
Name=wl*

[Link]
Unmanaged=yes
EOF

# Reload systemd to apply the override and enable Docker
sudo systemctl daemon-reload
sudo systemctl restart systemd-networkd
sudo systemctl restart docker