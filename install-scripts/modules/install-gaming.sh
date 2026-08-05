#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    steam \
    gamemode \
    gamescope \
    mangohud

info "Adding $USER to the gamemode group..."
run_cmd sudo usermod -aG gamemode "$USER"

stow_config MangoHud ~/.config/MangoHud

install_proton_ge() {
    local install_dir="$HOME/.local/share/Steam/compatibilitytools.d"
    local api="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

    info "Fetching latest Proton-GE release info..."
    local release tag url
    release=$(curl -fsSL "$api")
    tag=$(grep -oP '"tag_name":\s*"\K[^"]+' <<<"$release")
    url=$(grep -oP '"browser_download_url":\s*"\K[^"]+\.tar\.gz' <<<"$release" | grep -v -- '-aarch64\.tar\.gz$')

    if [ -d "$install_dir/$tag" ]; then
        ok "Proton-GE $tag already installed"
        return 0
    fi

    if [ "${DRY_RUN}" = true ]; then
        info "[DRY-RUN] download and extract Proton-GE $tag into $install_dir"
        return 0
    fi

    info "Downloading and extracting Proton-GE $tag..."
    mkdir -p "$install_dir"
    curl -fL "$url" | tar -xzf - -C "$install_dir"
    ok "Proton-GE $tag installed"
    warn "Restart Steam and pick $tag under Compatibility."
}

install_proton_ge
