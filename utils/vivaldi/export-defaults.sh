#!/bin/bash
# Refresh the saved Vivaldi defaults (settings.json, preferences.json,
# Bookmarks, AdBlockState) in this directory from your current live
# profile. Run this after you've tweaked settings/keybinds/bookmarks the
# way you want them, then commit the diff.
#
# settings.json holds the vivaldi.* preference namespace. Deliberately
# excludes vivaldi.vivaldi_account (refresh tokens), vivaldi.startup.keystore_canary
# (a per-device encrypted blob, meaningless on another machine),
# vivaldi.startup.active_days (usage timestamps) and vivaldi.list (transient
# selection cursors in manager UIs, which can embed dates like the last
# viewed day in the history manager).
#
# preferences.json holds a hand-picked allowlist of top-level (non
# vivaldi.*) Chromium prefs -- NOT the whole Preferences file, which also
# holds things like per-site browsing history (content_settings.exceptions)
# and signed-in account IDs. The search-engine entries have their
# usage/sync fields stripped since they aren't needed to restore the
# setting.
#
# AdBlockState carries the enabled filter-list subscriptions (public list
# URLs/titles only -- no browsing data) so "Block Trackers and Ads" survives
# a fresh install.
#
# Nothing account-tied or device-tied ends up in this (public) repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$HOME/.config/vivaldi/Default"

if pgrep -x 'vivaldi-bin|vivaldi' >/dev/null 2>&1; then
    echo "Vivaldi is running. Close it first so the profile is flushed to disk." >&2
    exit 1
fi

jq '.vivaldi | del(.vivaldi_account, .startup.keystore_canary, .startup.active_days, .list)' \
    "$PROFILE_DIR/Preferences" > "$SCRIPT_DIR/settings.json"

jq '{
  enable_do_not_track,
  credentials_enable_service,
  session,
  default_search_provider_data: (.default_search_provider_data
    | map_values(del(.last_visited, .last_modified, .synced_guid, .position)))
}' "$PROFILE_DIR/Preferences" > "$SCRIPT_DIR/preferences.json"

jq 'del(.sync_metadata)' "$PROFILE_DIR/Bookmarks" > "$SCRIPT_DIR/Bookmarks"

cp "$PROFILE_DIR/AdBlockState" "$SCRIPT_DIR/AdBlockState"

echo "Updated $SCRIPT_DIR/settings.json, preferences.json, Bookmarks and AdBlockState"
