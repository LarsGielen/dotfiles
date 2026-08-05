#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    qemu-full \
    virt-manager \
    virt-viewer \
    dnsmasq \
    libvirt

info "Enabling the libvirt daemon..."
run_cmd sudo systemctl enable --now libvirtd

info "Adding $USER to the libvirt group..."
run_cmd sudo usermod -aG libvirt "$USER"
ok "qemu configured"

