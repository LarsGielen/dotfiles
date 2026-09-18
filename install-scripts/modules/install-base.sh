#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# Each aspect stays a standalone, runnable script; this just runs them in order.
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/base" && pwd)"

# Bootstrap (git, yay, stow) first so the rest can use git, the AUR, and
# stow_config. 'theme' generates the colour configs that hyprland, quickshell,
# kitty and starship stow, so it has to come before them.
BASE_MODULES=(
    git yay stow
    drivers tunables audio video bluetooth xppentablet
    theme
    hyprland quickshell
    keyboard kitty
    shells starship yazi
    snapper ufw
    cli-tools general
)

aspect_path() { echo "$BASE_DIR/install-$1.sh"; }

# Unlike install-all.sh, stop at the first failure: every aspect after it may
# rely on what it installs (yay for AUR packages, theme for stowed colours).
run_modules stop base aspect_path "${BASE_MODULES[@]}"

ok "base system installed"
