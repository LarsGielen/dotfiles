#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

install_packages \
    blueman \
    bluez \
    bluez-utils

info "Enabling bluetooth service..."
run_cmd sudo systemctl enable --now bluetooth.service
ok "bluetooth enabled"

# quickshell has its own Bluetooth tile, so blueman's tray applet is
# redundant; this suppresses it however it gets started.
AUTOSTART_DIR="$HOME/.config/autostart"
BLUEMAN_OVERRIDE="$AUTOSTART_DIR/blueman.desktop"
info "Disabling blueman tray applet..."
if [ "${DRY_RUN}" = true ]; then
    info "[DRY-RUN] write $BLUEMAN_OVERRIDE (Hidden=true)"
else
    mkdir -p "$AUTOSTART_DIR"
    cat >"$BLUEMAN_OVERRIDE" <<'EOF'
[Desktop Entry]
Hidden=true
EOF
fi
# blueman-manager D-Bus-activates the applet directly, bypassing the override
# above, so the tray icon itself has to be turned off at the plugin level.
# ShowConnected depends on StatusIcon, so disabling only StatusIcon still gets
# it pulled back in by dependency resolution -- ShowConnected must go too.
run_cmd gsettings set org.blueman.general plugin-list \
    "['!StatusIcon', '!StatusNotifierItem', '!ShowConnected']"
ok "blueman tray applet disabled"
