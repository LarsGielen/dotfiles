#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    wireguard-tools \
    systemd-resolvconf \
    nftables \
    libnotify   # notify-send, used by the quickshell VPN widget's drop alert

run_cmd systemctl enable --now systemd-resolved

# /etc/wireguard holds wg-quick profiles (drop ProtonVPN's .conf exports here);
# the quickshell quick-settings VPN widget picks them up by filename. Group-own
# it to wheel so that widget can list profile *names* without a privilege
# prompt on every open — the .conf files themselves stay root-only since they
# contain private keys, and wg-quick still needs pkexec to bring a tunnel up
# or down.
info "Setting up /etc/wireguard..."
run_cmd sudo install -d -m 750 -o root -g wheel /etc/wireguard
