#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

install_packages \
    amd-ucode \
    nvidia-open \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings \
    egl-wayland
