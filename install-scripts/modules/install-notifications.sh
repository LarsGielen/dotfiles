#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    swaync \
    libnotify \
    ttf-jetbrains-mono-nerd

stow_config swaync ~/.config/swaync
