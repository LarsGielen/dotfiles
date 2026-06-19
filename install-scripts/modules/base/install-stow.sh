#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# GNU Stow: used by stow_config to symlink dotfiles into place.
install_packages \
    stow
