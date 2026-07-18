#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages vivaldi jq

profile_dir="$HOME/.config/vivaldi/Default"
defaults_dir="$DOTFILES_DIR/utils/vivaldi"

if pgrep -x 'vivaldi-bin|vivaldi' >/dev/null 2>&1; then
    warn "Vivaldi is running; skipping settings/bookmarks apply (close it and re-run this module)"
else
    info "Applying saved Vivaldi settings and bookmarks"
    run_cmd mkdir -p "$profile_dir"

    prefs="$profile_dir/Preferences"
    base="{}"
    if [ -f "$prefs" ]; then
        base="$(cat "$prefs")"
    fi
    merged="$(jq --slurpfile settings "$defaults_dir/settings.json" \
        '.vivaldi = ((.vivaldi // {}) * $settings[0])' <<<"$base")"
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY-RUN] merge $defaults_dir/settings.json into $prefs"
    else
        echo "$merged" > "$prefs"
    fi

    run_cmd cp "$defaults_dir/Bookmarks" "$profile_dir/Bookmarks"
    ok "Vivaldi settings and bookmarks applied"
fi
