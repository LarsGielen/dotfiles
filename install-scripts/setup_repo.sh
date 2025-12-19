#!/bin/bash

ORIGINAL_DIR=$(pwd)
REPO_URL="https://github.com/LarsGielen/dotfiles"
REPO_NAME="dotfiles"

is_installed_git() {
    pacman -Qi git &> /dev/null
}

cd ~

echo "Installing git..."
sudo pacman -S --needed --noconfirm \
    git \
    github-cli \
    git-lfs

if ! is_installed_git; then
    echo "Git is not installed."
    exit 1
fi

# Check if the dotfiles repository already exists
if [ -d "$REPO_NAME" ]; then
    echo "Dotfiles repository already exists. Pulling latest changes..."
    cd "$REPO_NAME" || exit 1
    git pull origin main
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