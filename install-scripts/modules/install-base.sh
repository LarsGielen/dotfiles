#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# Each aspect stays a standalone, runnable script; this just runs them in order.
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/base" && pwd)"

# Bootstrap (git, yay, stow) first so the rest can use git, the AUR, and
# stow_config. 'theme' generates the colour configs that hyprland, quickshell,
# kitty and starship stow, so it has to come before them.
BASE_MODULES=(
    git yay stow
    drivers audio video bluetooth
    theme
    hyprland quickshell
    keyboard kitty
    shells starship yazi
    snapper ufw
    cli-tools general
)

for m in "${BASE_MODULES[@]}"; do
    script="$BASE_DIR/install-$m.sh"
    [ -f "$script" ] || die "Base aspect not found: $script"
    info "${C_BOLD}>>> base: $m${C_RESET}"
    bash "$script"
done

ok "base system installed"
