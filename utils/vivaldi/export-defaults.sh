#!/bin/bash
# Refresh the saved Vivaldi defaults (settings.json, Bookmarks) in this
# directory from your current live profile. Run this after you've tweaked
# settings/keybinds/bookmarks the way you want them, then commit the diff.
#
# Deliberately excludes vivaldi.vivaldi_account (refresh tokens),
# vivaldi.startup.keystore_canary (a per-device encrypted blob, meaningless
# on another machine) and Bookmarks.sync_metadata (sync engine state) so
# nothing account-tied or device-tied ends up in this (public) repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$HOME/.config/vivaldi/Default"

if pgrep -x 'vivaldi-bin|vivaldi' >/dev/null 2>&1; then
    echo "Vivaldi is running. Close it first so the profile is flushed to disk." >&2
    exit 1
fi

jq '.vivaldi | del(.vivaldi_account, .startup.keystore_canary)' "$PROFILE_DIR/Preferences" > "$SCRIPT_DIR/settings.json"
jq 'del(.sync_metadata)' "$PROFILE_DIR/Bookmarks" > "$SCRIPT_DIR/Bookmarks"

echo "Updated $SCRIPT_DIR/settings.json and $SCRIPT_DIR/Bookmarks"
