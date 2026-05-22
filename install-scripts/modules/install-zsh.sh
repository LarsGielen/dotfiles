#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

# zsh - Z shell and useful plugins/utilities
# fzf - A command-line fuzzy finder
# zoxide - A smarter cd command
install_packages \
    zsh \
    fzf \
    zoxide

# Set Zsh as the default shell for the current user
info "Setting zsh as the default shell..."
run_cmd sudo chsh -s "$(command -v zsh)"

stow_config zsh ~/.zshrc ~/.zprofile
