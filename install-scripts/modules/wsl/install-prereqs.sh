#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# A fresh Arch WSL rootfs is `base` plus an empty package database: the first
# `pacman -S` fails with "target not found" before a mirror has ever been
# contacted. Arch has no supported partial upgrade, so refresh and upgrade in
# one go rather than a bare -Sy.
info "Refreshing the package database..."
run_progress sudo pacman -Syu --noconfirm

# What the shared base aspects take for granted on a desktop install:
# python runs theme/generate.py, the other two are pulled in by the desktop
# stack there but not by `base`.
install_packages \
    python \
    less \
    which
