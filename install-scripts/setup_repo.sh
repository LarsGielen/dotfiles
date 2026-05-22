#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

install_packages \
    git \
    github-cli \
    git-lfs

if [ -d "$DOTFILES_DIR" ]; then
    info "Dotfiles repository already exists. Pulling latest changes..."
    run_cmd git -C "$DOTFILES_DIR" pull origin main
else
    info "Cloning dotfiles repository..."
    run_quiet git clone "$REPO_URL" "$DOTFILES_DIR"
fi

ok "Repository ready at $DOTFILES_DIR"
