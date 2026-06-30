#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

install_packages \
    amd-ucode \
    nvidia-open \
    nvidia-utils \
    lib32-nvidia-utils \
    nvidia-settings \
    egl-wayland

NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
if ! grep -q 'nvidia' /etc/mkinitcpio.conf; then
    info "Adding NVIDIA early KMS modules to mkinitcpio.conf..."
    run_cmd sudo sed -i "s/^MODULES=(/MODULES=($NVIDIA_MODULES /" /etc/mkinitcpio.conf
fi