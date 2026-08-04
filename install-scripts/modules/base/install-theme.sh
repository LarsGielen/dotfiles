#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# Generates the per-app theme configs from theme/palettes.toml. Must run before
# the hyprland/quickshell/kitty aspects, since it writes into their stow
# packages (hypr/colors.lua, kitty/current-theme.conf, Theme/Palettes.qml).

require_cmd python3

GENERATE="$DOTFILES_DIR/theme/generate.py"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme"

# Pick a palette on first install, the same way install-hyprland.sh picks a
# machine profile. Afterwards the state file is authoritative, and
# theme/switch.sh is how you change it.
if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] select colour palette -> $STATE_FILE"
elif [ ! -f "$STATE_FILE" ]; then
    mapfile -t PALETTES < <(python3 "$GENERATE" --list)
    info "Available colour palettes:"
    select CHOSEN_PALETTE in "${PALETTES[@]}"; do
        if [[ -n "$CHOSEN_PALETTE" ]]; then
            break
        else
            warn "Invalid selection."
        fi
    done
    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$CHOSEN_PALETTE" >"$STATE_FILE"
else
    info "Using existing palette: $(cat "$STATE_FILE")"
fi

# No --palette: the generator resolves it from the state file we just wrote.
if [ "${DRY_RUN}" = true ]; then
    run_cmd python3 "$GENERATE" --dry-run
else
    python3 "$GENERATE"
fi

ok "theme configs generated"
