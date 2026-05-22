#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    pipewire \
    wireplumber \
    pipewire-pulse \
    pavucontrol
