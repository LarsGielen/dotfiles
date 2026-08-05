#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# General desktop odds and ends that don't belong to a specific app.

install_packages xdg-user-dirs

# XDG user dirs: only Downloads and Projects get their own folder, the rest
# point at $HOME so xdg-user-dirs-update doesn't scatter Desktop/, Templates/,
# Public/, ... around. Written directly instead of stowed, because
# xdg-user-dirs-update rewrites this file in place and would clobber the repo
# through the symlink.
USER_DIRS="$HOME/.config/user-dirs.dirs"

info "Writing XDG user dirs..."
if [ "${DRY_RUN}" = true ]; then
    echo "[DRY-RUN] write $USER_DIRS"
else
    # A leftover symlink from when this was a stow package would redirect the
    # write back into $DOTFILES_DIR.
    if [ -L "$USER_DIRS" ]; then
        rm -f "$USER_DIRS"
    fi
    mkdir -p "$(dirname "$USER_DIRS")"
    cat >"$USER_DIRS" <<'EOF'
# Managed by dotfiles (install-scripts/modules/base/install-general.sh).
# Format is XDG_xxx_DIR="$HOME/yyy" (homedir-relative) or "/yyy" (absolute).
XDG_DOWNLOAD_DIR="$HOME/Downloads"
XDG_PROJECTS_DIR="$HOME/Projects"
XDG_DESKTOP_DIR="$HOME/"
XDG_TEMPLATES_DIR="$HOME/"
XDG_PUBLICSHARE_DIR="$HOME/"
XDG_DOCUMENTS_DIR="$HOME/"
XDG_MUSIC_DIR="$HOME/"
XDG_PICTURES_DIR="$HOME/"
XDG_VIDEOS_DIR="$HOME/"
EOF
fi
ok "XDG user dirs configured"
