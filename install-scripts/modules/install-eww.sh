#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_aur eww

install_packages \
    stow \
    ttf-jetbrains-mono-nerd

stow_config eww ~/.config/eww
