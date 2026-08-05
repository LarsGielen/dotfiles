#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages zed ttf-jetbrains-mono-nerd

stow_config editor_zed ~/.config/zed

install_packages rustup gcc
run_cmd rustup default stable
run_cmd rustup component add rust-analyzer rust-src
