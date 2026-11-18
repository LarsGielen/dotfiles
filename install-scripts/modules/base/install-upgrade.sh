#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# Arch has no supported partial upgrade: installing one package against newer
# sync databases breaks its neighbours (openssl, systemd, gstreamer). Upgrade
# first so every later `pacman -S` resolves against a consistent system.
info "Upgrading the system..."
run_progress sudo pacman -Syu --noconfirm
