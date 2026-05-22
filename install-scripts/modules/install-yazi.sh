#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# yazi - Terminal file manager
# ffmpeg - For video thumbnails
# 7zip - For archive extraction
# zoxide - For historical file navigation
# wl-clipboard - For clipboard integration (Wayland)
install_packages \
    yazi \
    ffmpeg \
    7zip \
    zoxide \
    wl-clipboard

stow_config yazi ~/.config/yazi
