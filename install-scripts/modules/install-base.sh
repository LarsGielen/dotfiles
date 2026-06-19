#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# The 'base' module is a single entry that delegates to the per-aspect scripts
# in modules/base/. Each aspect stays a standalone, runnable script; this just
# runs them in a sensible order.
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/base" && pwd)"

# Aspects of the base system, in install order.
# Bootstrap (git, yay) first so the rest can use git and the AUR.
BASE_MODULES=(
    git yay
    drivers audio video bluetooth
    hyprland quickshell rofi
    keyboard kitty
    shells starship yazi
    snapper ufw reflector plymouth
    cli-tools
)

for m in "${BASE_MODULES[@]}"; do
    script="$BASE_DIR/install-$m.sh"
    [ -f "$script" ] || die "Base aspect not found: $script"
    info "${C_BOLD}>>> base: $m${C_RESET}"
    bash "$script"
done

ok "base system installed"
