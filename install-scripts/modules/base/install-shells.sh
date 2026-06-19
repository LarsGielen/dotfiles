#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# Shells and their configs.
# fzf    - command-line fuzzy finder
# zoxide - a smarter cd command
install_packages \
    bash \
    zsh \
    fzf \
    zoxide

stow_config bash ~/.bashrc ~/.bash_profile
stow_config zsh ~/.zshrc ~/.zprofile

# Make zsh the default shell for the current user.
info "Setting zsh as the default shell..."
run_cmd sudo chsh -s "$(command -v zsh)"
