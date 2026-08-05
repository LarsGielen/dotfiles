#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# fzf and zoxide are initialised by .zshrc, so they ship with the shells.
install_packages \
    bash \
    zsh \
    fzf \
    zoxide

stow_config bash ~/.bashrc ~/.bash_profile
stow_config zsh ~/.zshrc ~/.zprofile

# Make zsh the default shell for the current user. chsh always asks for a
# password, so only run it when the login shell isn't zsh already. $SHELL is
# inherited from the parent process and can be stale, so read passwd instead.
ZSH_PATH="$(command -v zsh)"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
    ok "zsh is already the default shell"
else
    info "Setting zsh as the default shell..."
    run_cmd chsh -s "$ZSH_PATH"
fi
