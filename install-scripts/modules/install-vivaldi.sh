#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages vivaldi jq

PROFILE_DIR="$HOME/.config/vivaldi/Default"
DEFAULTS_DIR="$DOTFILES_DIR/utils/vivaldi"
PREFS="$PROFILE_DIR/Preferences"

if pgrep -x 'vivaldi-bin|vivaldi' >/dev/null 2>&1; then
    warn "Vivaldi is running; skipping settings/bookmarks apply (close it and re-run this module)"
else
    info "Applying saved Vivaldi settings and bookmarks..."
    run_cmd mkdir -p "$PROFILE_DIR"

    BASE="{}"
    if [ -f "$PREFS" ]; then
        BASE="$(cat "$PREFS")"
    fi
    MERGED="$(jq --slurpfile settings "$DEFAULTS_DIR/settings.json" \
        '.vivaldi = ((.vivaldi // {}) * $settings[0])' <<<"$BASE")"
    if [ "${DRY_RUN}" = true ]; then
        info "[DRY-RUN] merge $DEFAULTS_DIR/settings.json into $PREFS"
    else
        printf '%s\n' "$MERGED" >"$PREFS"
    fi

    run_cmd cp "$DEFAULTS_DIR/Bookmarks" "$PROFILE_DIR/Bookmarks"
    ok "Vivaldi settings and bookmarks applied"
fi
