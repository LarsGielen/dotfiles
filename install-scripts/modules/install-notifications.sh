#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    stow \
    swaync \
    libnotify \
    ttf-jetbrains-mono-nerd

stow_config swaync ~/.config/swaync
