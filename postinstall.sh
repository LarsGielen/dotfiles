#!/bin/bash

sudo pacman -S --needed --noconfirm git github-cli base-devel nano stow man-db

# check if yay is installed
if ! command -v yay &> /dev/null; then 
	echo "yay not found. installing yay..."
	temp_dir=$(mktemp -d)
	git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
	cd "$temp_dir/yay" || exit 1
	makepkg -si
	cd ~
	rm -rf "$temp_dir"
	echo "yay installed succesfully."
else
	echo "yay already installed."
fi

# install drivers
sudo pacman -S --needed --noconfirm amd-ucode nvidia-open nvidia-utils lib32-nvidia-utils

# install dotfiles
DOTFILES_DIR="$HOME/dotfiles"
GIT_REPO_URL="https://github.com/LarsGielen/dotfiles.git"

if [ -d "$DOTFILES_DIR" ]; then
	echo "Dotfiles already exist."
else
	git clone "$GIT_REPO_URL"  "$DOTFILES_DIR"
	cd "$DOTFILES_DIR"
	stow . --dotfiles
	cd ~
fi

# install hyprland
sudo pacman -S --needed --noconfirm uwsm libnewt hyprland egl-wayland waybar rofi hyprpaper libnotify dunst

# install fonts
sudo pacman -S --needed --noconfirm ttf-fira-sans ttf-font-awesome ttf-roboto ttf-dejavu ttf-liberation

# install basic control applications
sudo pacman -S --needed --noconfirm pipewire wireplumber hyprpolkitagent xdg-desktop-portal-hyprland qt5-wayland qt6-wayland xorg-xhost

# install applications
sudo pacman -S --needed --noconfirm kitty pavucontrol blueman 
yay -S --needed --noconfirm zen-browser-bin visual-studio-code-bin checkupdates-with-aur

#enable services
systemctl --user enable --now hyprpolkitagent.service
sudo systemctl enable bluetooth 

echo "Everything is installed, DONT FORGET TO ENABLE SYSTEM SERVICES AND FIREWALL, I CANT DO EVERYTHING FOR YOU!!"
