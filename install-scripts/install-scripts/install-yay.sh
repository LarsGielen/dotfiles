#!/bin/bash
echo "Installing yay..."

is_installed_git() {
    pacman -Qi git &> /dev/null
}

if ! is_installed_git; then
    echo "Git is not installed."
    exit 1
fi

sudo pacman -S --needed --noconfirm base-devel

# check if yay is installed
if ! command -v yay &> /dev/null; then 
	echo "yay not found. installing yay..."
	temp_dir=$(mktemp -d)
	git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"
	cd "$temp_dir/yay" || exit 1
	makepkg -si
	cd ~
	rm -rf "$temp_dir"
	echo "yay installed successfully."
else
	echo "yay already installed."
fi