#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

install_packages \
    yazi \
    ffmpeg \
    7zip \
    zoxide \
    wl-clipboard

stow_config yazi ~/.config/yazi

# For picking files from the terminal inside yazi
install_aur \
    xdg-desktop-portal-termfilechooser-hunkyburrito-git
    
PORTAL_CONFIG_DIR="$HOME/.config/xdg-desktop-portal-termfilechooser"
PORTAL_MAP_DIR="$HOME/.config/xdg-desktop-portal"
mkdir -p "$PORTAL_CONFIG_DIR" "$PORTAL_MAP_DIR"

cat <<EOF > "$PORTAL_CONFIG_DIR/config"
[filechooser]
cmd=$HOME/.config/yazi/scripts/yazi-picker.sh
default_dir=\$HOME
open_mode=suggested
save_mode=last
EOF

cat <<EOF > "$PORTAL_MAP_DIR/portals.conf"
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=termfilechooser
EOF