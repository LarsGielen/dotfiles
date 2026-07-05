#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# Hyprland and core session bits
install_packages \
    uwsm \
    libnewt \
    hyprland

# Hyprland dependencies
# Note: the polkit authentication agent is provided by the Quickshell shell
# (Components/Polkit/PolkitPrompt.qml), so hyprpolkitagent is intentionally not
# installed or enabled here — only one polkit agent can serve the session.
install_packages \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    qt5-wayland \
    qt6-wayland \
    xorg-xhost

# Fonts
install_packages noto-fonts-emoji

# Cursor themes
install_aur \
    rose-pine-hyprcursor \
    rose-pine-cursor

# Hyprland utilities
install_packages \
    hyprpaper \
    hyprsunset
install_aur hyprshot

# Configure machine-specific Hyprland config
MACHINE_LUA="$DOTFILES_DIR/stow/hyprland/.config/hypr/machine.lua"
if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] select machine-specific Hyprland config -> $MACHINE_LUA"
elif [ ! -f "$MACHINE_LUA" ]; then
    HYPR_CONFIG_DIR="$DOTFILES_DIR/stow/hyprland/.config/hypr/config"
    mapfile -t OPTIONS < <(ls -1 "$HYPR_CONFIG_DIR")
    info "Available Hyprland config options:"
    select CHOSEN_OPTION in "${OPTIONS[@]}"; do
        if [[ -n "$CHOSEN_OPTION" ]]; then
            break
        else
            warn "Invalid selection."
        fi
    done
    mkdir -p "$(dirname "$MACHINE_LUA")"
    echo "require(\"config.$CHOSEN_OPTION._hyprland-$CHOSEN_OPTION\")" >> "$MACHINE_LUA"
fi

stow_config hyprland ~/.config/hypr
stow_config uwsm ~/.config/uwsm
