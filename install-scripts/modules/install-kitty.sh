#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    stow \
    kitty \
    ttf-jetbrains-mono-nerd

stow_config kitty ~/.config/kitty
