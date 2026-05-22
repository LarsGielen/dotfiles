#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    stow \
    steam \
    gamemode \
    gamescope \
    mangohud

info "Adding $USER to the gamemode group..."
run_cmd sudo usermod -aG gamemode "$USER"

stow_config MangoHud ~/.config/MangoHud
