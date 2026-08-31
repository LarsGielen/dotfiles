#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

install_packages \
    yazi \
    ffmpeg \
    7zip \
    zoxide \
    wl-clipboard

stow_config yazi ~/.config/yazi

# The rest wires yazi up as the file picker for GUI apps. A WSL distro has no
# desktop portal and no GUI apps asking for one, so it stops here.
if is_wsl; then
    ok "file picker portal skipped (no desktop portal under WSL)"
    exit 0
fi

install_aur xdg-desktop-portal-termfilechooser-hunkyburrito-git

PORTAL_CONFIG_DIR="$HOME/.config/xdg-desktop-portal-termfilechooser"
PORTAL_MAP_DIR="$HOME/.config/xdg-desktop-portal"

info "Configuring the terminal file picker portal..."
if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] write $PORTAL_CONFIG_DIR/config and $PORTAL_MAP_DIR/portals.conf"
else
    mkdir -p "$PORTAL_CONFIG_DIR" "$PORTAL_MAP_DIR"
    cat >"$PORTAL_CONFIG_DIR/config" <<EOF
[filechooser]
cmd=$HOME/.config/yazi/scripts/yazi-picker.sh
default_dir=\$HOME
open_mode=suggested
save_mode=last
EOF
    cat >"$PORTAL_MAP_DIR/portals.conf" <<'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=termfilechooser
EOF
fi
ok "file picker portal configured"
