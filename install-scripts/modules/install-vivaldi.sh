#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

PROFILE_DIR="$HOME/.config/vivaldi/Default"
DEFAULTS_DIR="$DOTFILES_DIR/utils/vivaldi"
BUNDLE="$DEFAULTS_DIR/profile.tar.gpg"
PREFS="$PROFILE_DIR/Preferences"

# Vivaldi reads Chromium's external-extensions dir. A file there installs the
# extension from the Web Store on next launch but, unlike a policy, still lets
# it be disabled or removed.
EXTERNAL_EXTENSIONS_DIR="/usr/share/chromium/extensions"
TAMPERMONKEY_ID="dhdgffkkebhmkfjojejmpbldmpobfkfo"
EXTENSIONS=(
    "$TAMPERMONKEY_ID"               # Tampermonkey
    ghmbeldphafepmbegfdlkpapadhbakde # Proton Pass
    jplgfhpmjnbigmhklmmbgecoobifkmpa # Proton VPN
    lmmnbhikidmfldabomkfdhkdnpbabcdm # CRX Launch
)

install_packages \
    vivaldi \
    jq \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    noto-fonts-extra \
    ttf-liberation \
    ttf-dejavu

run_cmd sudo mkdir -p "$EXTERNAL_EXTENSIONS_DIR"
for extension_id in "${EXTENSIONS[@]}"; do
    write_root_file "$EXTERNAL_EXTENSIONS_DIR/$extension_id.json" \
        '{ "external_update_url": "https://clients2.google.com/service/update2/crx" }'
done

apply_bundle() {
    local staging="$1" merged base="{}"

    run_cmd mkdir -p "$PROFILE_DIR"

    if [ -f "$PREFS" ]; then
        base="$(cat "$PREFS")"
    fi
    merged="$(jq --slurpfile settings "$staging/settings.json" \
        --slurpfile prefs "$staging/preferences.json" \
        --arg dir "$DOTFILES_DIR" \
        '. * $prefs[0] | .vivaldi = ((.vivaldi // {}) * $settings[0])
        | .vivaldi.appearance.css_ui_mods_directory |= sub("@DOTFILES_DIR@"; $dir)' <<<"$base")"
    printf '%s\n' "$merged" >"$PREFS"

    cp "$staging/Bookmarks" "$PROFILE_DIR/Bookmarks"
    cp "$staging/AdBlockState" "$PROFILE_DIR/AdBlockState"

    # Only seed Tampermonkey into a profile that doesn't have it yet: once it
    # exists, it holds scripts edited since the last export.
    local tampermonkey_dir="$PROFILE_DIR/Local Extension Settings/$TAMPERMONKEY_ID"
    if [ ! -d "$staging/tampermonkey" ]; then
        warn "Bundle has no Tampermonkey storage; userscripts not restored"
    elif [ -d "$tampermonkey_dir" ]; then
        ok "Tampermonkey storage already present; userscripts left as is"
    else
        mkdir -p "$(dirname "$tampermonkey_dir")"
        cp -r "$staging/tampermonkey" "$tampermonkey_dir"
        chmod -R go= "$tampermonkey_dir"
        ok "Tampermonkey userscripts restored"
    fi
}

if [ ! -f "$BUNDLE" ]; then
    warn "No $BUNDLE yet; run utils/vivaldi/export-defaults.sh on a configured machine"
elif pgrep -x 'vivaldi-bin|vivaldi' >/dev/null 2>&1; then
    warn "Vivaldi is running; skipping settings/bookmarks apply (close it and re-run this module)"
elif [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] decrypt $BUNDLE and apply settings, bookmarks, adblock and userscripts to $PROFILE_DIR"
else
    info "Decrypting and applying saved Vivaldi profile..."
    STAGING="$(mktemp -d -p "${XDG_RUNTIME_DIR:-/tmp}" vivaldi-install.XXXXXX)"
    trap 'rm -rf "$STAGING"' EXIT
    gpg --quiet --pinentry-mode loopback --decrypt "$BUNDLE" | tar -C "$STAGING" -xf -
    apply_bundle "$STAGING"
    ok "Vivaldi settings and bookmarks applied"
fi
