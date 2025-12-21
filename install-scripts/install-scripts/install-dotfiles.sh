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

HYPR_CONFIG_DIR="$HOME/$REPO_NAME/stow/hyprland/.config/hypr/config"
OPTIONS=($(ls -1 "$HYPR_CONFIG_DIR"))
echo "Available Hyprland config options:"
select CHOSEN_OPTION in "${OPTIONS[@]}"; do
    if [[ -n "$CHOSEN_OPTION" ]]; then
        break
    else
        echo "Invalid selection."
    fi
done

HYPR_CONF="$HOME/$REPO_NAME/stow/hyprland/.config/hypr/hyprland.conf"
# Remove last line containing "source"
sed -i '${/source/d;}' "$HYPR_CONF"
# Add new source line
echo "source = ~/.config/hypr/config/$CHOSEN_OPTION/_hyprland-$CHOSEN_OPTION.conf" >> "$HYPR_CONF"

echo "Removing old configs..."
rm -rf ~/.bashrc
rm -rf ~/.bash_profile
rm -rf ~/.zshrc
rm -rf ~/.zprofile

rm -rf ~/.config/eww
rm -rf ~/.config/gtk-3.0
rm -rf ~/.config/hypr
rm -rf ~/.config/kitty
rm -rf ~/.config/rofi
rm -rf ~/.config/starship.toml
rm -rf ~/.config/uwsm
rm -rf ~/.config/waybar
rm -rf ~/.config/yazi

echo "stowing dotfiles..."
cd ~/$REPO_NAME/stow || exit 1
stow -t ~ bash
stow -t ~ eww
stow -t ~ gtk
stow -t ~ hyprland
stow -t ~ kitty
stow -t ~ rofi
stow -t ~ starship
stow -t ~ uwsm
stow -t ~ waybar
stow -t ~ zsh
stow -t ~ yazi

cd "$ORIGINAL_DIR" || exit 1