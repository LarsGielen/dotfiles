#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    stow \
    waybar \
    ttf-jetbrains-mono-nerd

stow_config waybar ~/.config/waybar
