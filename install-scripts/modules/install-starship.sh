#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    stow \
    starship \
    ttf-jetbrains-mono-nerd

stow_config starship ~/.config/starship.toml
