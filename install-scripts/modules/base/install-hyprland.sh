#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

install_packages \
    uwsm \
    libnewt \
    hyprland

# The polkit authentication agent is provided by the Quickshell shell
# (Components/Polkit/PolkitPrompt.qml), so hyprpolkitagent is intentionally not
# installed or enabled here — only one polkit agent can serve the session.
install_packages \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland \
    xorg-xhost

install_packages noto-fonts-emoji

install_aur \
    rose-pine-hyprcursor \
    rose-pine-cursor

install_packages \
    hyprpaper \
    hyprsunset
install_aur hyprshot

# machine.lua layers the machine profile's Hyprland overrides on top of
# config/default/. It is regenerated on every run, so switching profiles
# (~/.local/state/dotfiles/machine) carries through.
load_profile
HYPR_DIR="$DOTFILES_DIR/stow/hyprland/.config/hypr"
MACHINE_LUA="$HYPR_DIR/machine.lua"
if [ -f "$HYPR_DIR/config/$MACHINE/_hyprland-$MACHINE.lua" ]; then
    MACHINE_LUA_BODY="require(\"config.$MACHINE._hyprland-$MACHINE\")"
else
    MACHINE_LUA_BODY="-- The '$MACHINE' machine profile has no Hyprland overrides."
fi

if [ "$(cat "$MACHINE_LUA" 2>/dev/null)" = "$MACHINE_LUA_BODY" ]; then
    ok "machine.lua already selects '$MACHINE'"
elif [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] write $MACHINE_LUA for '$MACHINE'"
else
    info "Selecting the '$MACHINE' Hyprland profile..."
    printf '%s\n' "$MACHINE_LUA_BODY" >"$MACHINE_LUA"
fi

stow_config hyprland ~/.config/hypr
stow_config uwsm ~/.config/uwsm
