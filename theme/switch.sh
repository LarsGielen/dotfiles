#!/usr/bin/env bash

# Activate a colour palette across the whole system.
#   theme/switch.sh              show the active palette and the available ones
#   theme/switch.sh catppuccin   switch everything to catppuccin

COMMON_AUTO_PARSE=false
source "$(dirname "${BASH_SOURCE[0]}")/../install-scripts/lib/common.sh"

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATE="$THEME_DIR/generate.py"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/theme"

usage() {
    cat <<EOF
Usage: $(basename "$0") [palette] [--dry-run]

Activates a colour palette across quickshell, Hyprland, kitty and Zed.
With no palette, prints the active one and lists the alternatives.

Options:
  --dry-run      Print actions without changing anything
  --help, -h     Show this help
EOF
}

PALETTE=""
for arg in "$@"; do
    case "$arg" in
        --dry-run)  DRY_RUN=true ;;
        --help|-h)  usage; exit 0 ;;
        -*)         die "Unknown argument: $arg" ;;
        *)
            [ -n "$PALETTE" ] && die "Only one palette can be given (got '$PALETTE' and '$arg')"
            PALETTE="$arg"
            ;;
    esac
done

require_cmd python3

mapfile -t AVAILABLE < <(python3 "$GENERATE" --list)
[ ${#AVAILABLE[@]} -eq 0 ] && die "No palettes defined in theme/palettes.toml"

current() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "(unset)"
    fi
}

# No palette given: report and exit without touching anything.
if [ -z "$PALETTE" ]; then
    info "Active palette: $(current)"
    info "Available: ${AVAILABLE[*]}"
    exit 0
fi

found=false
for name in "${AVAILABLE[@]}"; do
    [ "$name" = "$PALETTE" ] && found=true
done
[ "$found" = true ] || die "Unknown palette '$PALETTE' (available: ${AVAILABLE[*]})"

# Generate first: a failure here leaves the state file untouched, so the
# running session keeps whatever was already working.
info "Switching to $PALETTE"
if [ "${DRY_RUN}" = true ]; then
    python3 "$GENERATE" --palette "$PALETTE" --dry-run
else
    python3 "$GENERATE" --palette "$PALETTE"
fi

run_cmd mkdir -p "$(dirname "$STATE_FILE")"
if [ "${DRY_RUN}" = true ]; then
    echo "[DRY-RUN] write '$PALETTE' to $STATE_FILE"
else
    printf '%s\n' "$PALETTE" >"$STATE_FILE"
fi

# quickshell hot-reloads its own config; Zed watches its themes dir.
if command -v hyprctl >/dev/null 2>&1 && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    run_quiet hyprctl reload && ok "Hyprland reloaded"
fi

if pgrep -x kitty >/dev/null 2>&1; then
    # SIGUSR1 makes kitty re-read its config; no allow_remote_control needed.
    run_cmd pkill -SIGUSR1 -x kitty && ok "kitty reloaded"
fi

ok "Palette set to $PALETTE"
