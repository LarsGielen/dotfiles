#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

install_packages \
    rofi-wayland \
    ttf-roboto

stow_config rofi ~/.config/rofi
