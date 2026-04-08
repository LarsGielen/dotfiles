#!/bin/bash

# zsh - Z shell and useful plugins/utilities
# fzf - A command-line fuzzy finder
# zoxide - A smarter cd command

REPO_NAME="dotfiles"

sudo pacman -S --needed --noconfirm \
    stow \
    zsh \
    fzf \
    zoxide

# Set Zsh as the default shell for the current user
sudo chsh -s "$(which zsh)"

rm -rf ~/.zshrc
rm -rf ~/.zprofile

stow -d ~/$REPO_NAME/stow -t ~ zsh

echo "zsh installed and configured successfully!"
