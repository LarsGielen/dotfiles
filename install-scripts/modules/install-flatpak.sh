#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages flatpak

# flatpak_install [remote] <app-id> -- the app id is the last argument
flatpak_install() {
    local app="${*: -1}"
    if flatpak info "$app" >/dev/null 2>&1; then
        ok "flatpak $app already installed"
        return 0
    fi
    info "Installing flatpak: $app..."
    run_quiet flatpak install -y "$@"
    ok "flatpak $app installed"
}

flatpak_install flathub com.github.tchx84.Flatseal
flatpak_install flathub com.usebottles.bottles
flatpak_install flathub org.musescore.MuseScore
flatpak_install flathub md.obsidian.Obsidian
flatpak_install flathub com.discordapp.Discord
