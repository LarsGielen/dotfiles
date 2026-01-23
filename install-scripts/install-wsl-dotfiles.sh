#!/bin/bash
echo "Installing dotfiles..."

ORIGINAL_DIR=$(pwd)
REPO_URL="https://github.com/LarsGielen/dotfiles"
REPO_NAME="dotfiles"

is_installed_stow() {
    pacman -Qi stow &> /dev/null
}

is_installed_git() {
    pacman -Qi git &> /dev/null
}

if ! is_installed_stow; then
    echo "GNU Stow is not installed."
    exit 1
fi

if ! is_installed_git; then
    echo "Git is not installed."
    exit 1
fi

cd ~

# Check if the dotfiles repository already exists
if [ -d "$REPO_NAME" ]; then
    echo "Dotfiles repository already exists. Pulling latest changes..."
    cd "$REPO_NAME" || exit 1
    # git pull origin main
    cd ~
else
    echo "Cloning dotfiles repository..."
    git clone "$REPO_URL"
fi

# Check if clone was successful
if [ $? -ne 0 ]; then
    echo "Failed to clone the dotfiles repository."
    exit 1
fi

echo "Removing old configs..."
rm -rf ~/.zshrc
rm -rf ~/.zprofile

rm -rf ~/.config/starship.toml
rm -rf ~/.config/yazi

echo "stowing dotfiles..."
cd ~/$REPO_NAME/stow || exit 1
stow -t ~ zsh
stow -t ~ starship
stow -t ~ yazi

cd "$ORIGINAL_DIR" || exit 1