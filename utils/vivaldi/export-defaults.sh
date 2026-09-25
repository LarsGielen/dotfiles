#!/bin/bash
# Refresh the encrypted Vivaldi bundle (profile.tar.gpg) in this directory
# from your current live profile. Run this after you've tweaked settings,
# keybinds, bookmarks or userscripts the way you want them, then commit the
# diff. install-vivaldi.sh decrypts it again on install.
#
# The bundle is gpg-symmetric (AES256, passphrase) because the repo is public
# and bookmarks and userscripts are personal. Plaintext only ever exists in a
# tmpfs staging dir that is wiped on exit.
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
# AdBlockState carries the enabled filter-list subscriptions so "Block
# Trackers and Ads" survives a fresh install.
#
# tampermonkey/ is Tampermonkey's chrome.storage LevelDB: its userscripts and
# settings. It's keyed by the Web Store extension ID, so it drops straight
# back into a new profile.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$HOME/.config/vivaldi/Default"
BUNDLE="$SCRIPT_DIR/profile.tar.gpg"
TAMPERMONKEY_ID="dhdgffkkebhmkfjojejmpbldmpobfkfo"

if pgrep -x 'vivaldi-bin|vivaldi' >/dev/null 2>&1; then
    echo "Vivaldi is running. Close it first so the profile is flushed to disk." >&2
    exit 1
fi

STAGING="$(mktemp -d -p "${XDG_RUNTIME_DIR:-/tmp}" vivaldi-export.XXXXXX)"
trap 'rm -rf "$STAGING"' EXIT
mkdir "$STAGING/bundle"

# The CSS mods path is absolute in the live profile; install-vivaldi.sh fills
# the placeholder back in.
jq '.vivaldi | del(.vivaldi_account, .startup.keystore_canary, .startup.active_days, .list)
    | .appearance.css_ui_mods_directory = "@DOTFILES_DIR@/utils/vivaldi-css"' \
    "$PROFILE_DIR/Preferences" >"$STAGING/bundle/settings.json"

jq '{
  enable_do_not_track,
  credentials_enable_service,
  session,
  default_search_provider_data: (.default_search_provider_data
    | map_values(del(.last_visited, .last_modified, .synced_guid, .position)))
}' "$PROFILE_DIR/Preferences" >"$STAGING/bundle/preferences.json"

jq 'del(.sync_metadata)' "$PROFILE_DIR/Bookmarks" >"$STAGING/bundle/Bookmarks"

cp "$PROFILE_DIR/AdBlockState" "$STAGING/bundle/AdBlockState"

# LOCK and LOG* are LevelDB runtime files, not data.
TAMPERMONKEY_DIR="$PROFILE_DIR/Local Extension Settings/$TAMPERMONKEY_ID"
if [ -d "$TAMPERMONKEY_DIR" ]; then
    mkdir "$STAGING/bundle/tampermonkey"
    find "$TAMPERMONKEY_DIR" -maxdepth 1 -type f ! -name LOCK ! -name 'LOG*' \
        -exec cp {} "$STAGING/bundle/tampermonkey/" \;
else
    echo "Tampermonkey storage not found; bundle will carry no userscripts." >&2
fi

# A reproducible tar, so an unchanged profile can be detected below.
tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner \
    -C "$STAGING/bundle" -cf "$STAGING/profile.tar" .

# gpg output differs on every run (random salt and session key), so
# re-encrypting an unchanged profile would commit a new multi-MB blob each time.
if [ -f "$BUNDLE" ]; then
    gpg --quiet --pinentry-mode loopback --decrypt --output "$STAGING/previous.tar" "$BUNDLE"
    if cmp -s "$STAGING/profile.tar" "$STAGING/previous.tar"; then
        echo "Vivaldi profile unchanged; $BUNDLE left as is"
        exit 0
    fi
fi

gpg --quiet --pinentry-mode loopback --symmetric --cipher-algo AES256 \
    --yes --output "$BUNDLE" "$STAGING/profile.tar"

echo "Updated $BUNDLE"
