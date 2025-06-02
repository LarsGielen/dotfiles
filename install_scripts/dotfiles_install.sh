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

###########################
### Desktop Environment ###
###########################

# install dotfiles
stow . --dotfiles

# install hyprland
sudo pacman -S --needed --noconfirm uwsm libnewt hyprland egl-wayland waybar rofi hyprpaper libnotify dunst

# install fonts
sudo pacman -S --needed --noconfirm ttf-fira-sans ttf-font-awesome ttf-roboto ttf-dejavu ttf-liberation

# install basic control applications
sudo pacman -S --needed --noconfirm pipewire wireplumber hyprpolkitagent xdg-desktop-portal-hyprland qt5-wayland qt6-wayland xorg-xhost

############################
### General Applications ###
############################

# install thunar and plugins
sudo pacman -S --needed --noconfirm thunar thunar-media-tags-plugin tumbler
# thunar auto mount support
sudo pacman -S --needed --noconfirm thunar-volman gvfs gvfs-mtp gvfs-smb gvfs-gphoto2 udisks2
# xarchiver with thunar support (extract here functionality)
sudo pacman -S --needed --noconfirm thunar-archive-plugin xarchiver p7zip tar unrar unzip

# printing support
sudo pacman -S --needed --noconfirm cups cups-pdf ghostscript gutenprint foomatic-db-engine

# other applications
sudo pacman -S --needed --noconfirm kitty pavucontrol blueman fastfetch htop vivaldi
yay -S --needed --noconfirm visual-studio-code-bin checkupdates-with-aur 

# Flatpak
sudo pacman -S --needed --noconfirm flatpak
flatpak install -y flathub com.github.tchx84.Flatseal 
flatpak install -y flathub md.obsidian.Obsidian 

#################################
### Post-installation cleanup ###
#################################
systemctl --user enable --now hyprpolkitagent.service
sudo systemctl enable --now cups.service
sudo systemctl enable --now bluetooth.service

echo "Everything is installed, DONT FORGET TO ENABLE SYSTEM SERVICES AND FIREWALL, I CANT DO EVERYTHING FOR YOU!!"
