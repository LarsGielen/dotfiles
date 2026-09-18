#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

KEYD_CONF="/etc/keyd/default.conf"
KEYD_SRC="$DOTFILES_DIR/system/keyd/default.conf"
KEYD_BODY="# Installed from system/keyd/default.conf by install-keyboard.sh -- edit there.
$(cat "$KEYD_SRC")"

install_packages keyd

# keyd used to be stowed into ~/.config/keyd and symlinked from /etc. A root
# daemon shouldn't read its config out of a home directory, and
# write_root_file would read and write straight through the old link, so both
# links go first.
if [ -L "$HOME/.config/keyd" ]; then
    run_cmd rm -f "$HOME/.config/keyd"
fi
prime_sudo
if [ -L "$KEYD_CONF" ]; then
    run_cmd sudo rm -f "$KEYD_CONF"
fi

changed=false
if [ "$(cat "$KEYD_CONF" 2>/dev/null)" != "$KEYD_BODY" ]; then
    changed=true
fi

run_cmd sudo mkdir -p /etc/keyd
write_root_file "$KEYD_CONF" "$KEYD_BODY"

info "Enabling keyd service..."
run_cmd sudo systemctl enable --now keyd
if [ "$changed" = true ]; then
    run_cmd sudo keyd reload
fi
ok "keyd configured"
