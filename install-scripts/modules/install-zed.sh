#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages zed ttf-jetbrains-mono-nerd

stow_config editor_zed ~/.config/zed
