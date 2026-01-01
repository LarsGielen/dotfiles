#!bin/bash

# zsh - Z shell and useful plugins/utilities
# fzf - A command-line fuzzy finder
# zoxide - A smarter cd command

echo "Installing Zsh and related utilities..."
sudo pacman -S --needed --noconfirm \
    zsh \
    fzf \
    zoxide

# Set Zsh as the default shell for the current user
sudo chsh -s $(which zsh)
