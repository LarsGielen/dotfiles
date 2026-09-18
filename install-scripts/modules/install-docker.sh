#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    docker \
    docker-compose \
    nvidia-container-toolkit \
    docker-buildx

info "Adding $USER to the docker group..."
run_cmd sudo usermod -aG docker "$USER"

info "Configuring the NVIDIA container runtime..."
run_quiet sudo nvidia-ctk runtime configure --runtime=docker

info "(Re)starting Docker..."
run_cmd sudo systemctl restart docker
ok "docker configured"
