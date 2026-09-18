#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

DAEMON_JSON="/etc/docker/daemon.json"

install_packages \
    docker \
    docker-compose \
    docker-buildx

# GPU containers only make sense where the NVIDIA driver is installed.
HAS_NVIDIA=false
if is_installed nvidia-utils; then
    HAS_NVIDIA=true
    install_packages nvidia-container-toolkit
fi

info "Adding $USER to the docker group..."
run_cmd sudo usermod -aG docker "$USER"

DAEMON_JSON_BEFORE="$(cat "$DAEMON_JSON" 2>/dev/null || true)"
if [ "$HAS_NVIDIA" = true ]; then
    info "Configuring the NVIDIA container runtime..."
    run_quiet sudo nvidia-ctk runtime configure --runtime=docker
fi

info "Enabling Docker..."
run_cmd sudo systemctl enable --now docker
if [ "$(cat "$DAEMON_JSON" 2>/dev/null || true)" != "$DAEMON_JSON_BEFORE" ]; then
    info "Restarting Docker for the new runtime config..."
    run_cmd sudo systemctl restart docker
fi
ok "docker configured"
