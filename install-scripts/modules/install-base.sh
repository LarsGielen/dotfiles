#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# The 'base' module is a single entry that delegates to the per-aspect scripts
# in modules/base/. Each aspect stays a standalone, runnable script; this just
# runs them in a sensible order.
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/base" && pwd)"

# Aspects of the base system, in install order.
# Bootstrap (git, yay, stow) first so the rest can use git, the AUR, and
# stow_config to symlink configs.
BASE_MODULES=(
    git yay stow
    drivers audio video bluetooth
    hyprland quickshell
    keyboard kitty
    shells starship yazi
    snapper ufw reflector
    cli-tools general
)

for m in "${BASE_MODULES[@]}"; do
    script="$BASE_DIR/install-$m.sh"
    [ -f "$script" ] || die "Base aspect not found: $script"
    info "${C_BOLD}>>> base: $m${C_RESET}"
    bash "$script"
done

ok "base system installed"
