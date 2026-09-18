#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

VENDOR="$(grep -m1 -oP '^vendor_id\s*:\s*\K\S+' /proc/cpuinfo || true)"

case "$VENDOR" in
    AuthenticAMD) install_packages amd-ucode ;;
    GenuineIntel) install_packages intel-ucode ;;
    *) warn "Unknown CPU vendor '$VENDOR'; no microcode installed" ;;
esac
