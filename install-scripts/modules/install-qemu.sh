#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages qemu-full virt-manager virt-viewer dnsmasq libvirt

run_cmd sudo systemctl enable --now libvirtd
run_cmd sudo usermod -aG libvirt "$USER"


