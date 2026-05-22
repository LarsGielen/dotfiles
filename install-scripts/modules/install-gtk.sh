#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    gtk3

stow_config gtk ~/.config/gtk-3.0
