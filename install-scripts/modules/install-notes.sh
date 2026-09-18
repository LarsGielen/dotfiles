#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_aur zotero-bin

flatpak_install md.obsidian.Obsidian
