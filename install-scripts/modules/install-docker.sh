#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# Host-specific: the wired interface docker should wait for at boot.
ETH_INTERFACE="eno1"

install_packages \
    docker \
    docker-compose \
    nvidia-container-toolkit \
    docker-buildx

info "Adding $USER to the docker group..."
run_cmd sudo usermod -aG docker "$USER"

info "Configuring the NVIDIA container runtime..."
run_quiet sudo nvidia-ctk runtime configure --runtime=docker

# Fix slow Docker startup: systemd-networkd-wait-online waits for all managed
# interfaces, including wifi (wlp9s0) which has no carrier. Override it to only
# wait for ethernet.
info "Limiting systemd-networkd-wait-online to ethernet..."
run_cmd sudo mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] write systemd-networkd-wait-online override.conf"
else
    sudo tee /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --interface=$ETH_INTERFACE
EOF
fi

# Mark wifi as unmanaged so it doesn't appear as a stray 'configuring' interface
if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] write /etc/systemd/network/99-ignore-wifi.network"
else
    sudo tee /etc/systemd/network/99-ignore-wifi.network > /dev/null <<EOF
[Match]
Name=wl*

[Link]
Unmanaged=yes
EOF
fi

# Reload systemd to apply the override and enable Docker
info "Reloading systemd and (re)starting Docker..."
run_cmd sudo systemctl daemon-reload
run_cmd sudo systemctl restart systemd-networkd
run_cmd sudo systemctl restart docker
ok "docker configured"
