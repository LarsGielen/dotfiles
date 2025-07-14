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

# drivers
sudo pacman -S --needed --noconfirm amd-ucode nvidia-open nvidia-utils lib32-nvidia-utils linux-headers

###########################
### Desktop Environment ###
###########################

# dotfiles
stow . --dotfiles

# hyprland
sudo pacman -S --needed --noconfirm uwsm libnewt hyprland egl-wayland waybar rofi-wayland hyprpaper libnotify dunst
yay -S --needed --noconfirm checkupdates-with-aur 

# install fonts
sudo pacman -S --needed --noconfirm ttf-fira-sans ttf-font-awesome ttf-roboto ttf-dejavu ttf-liberation noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-jetbrains-mono

# cursor theme
yay -S --needed --noconfirm rose-pine-hyprcursor rose-pine-cursor

# terminal
sudo pacman -S --needed --noconfirm kitty starship zsh fzf zoxide

# File systems
sudo pacman -S --needed --noconfirm ntfs-3g

# basic control applications
sudo pacman -S --needed --noconfirm pipewire wireplumber hyprpolkitagent xdg-desktop-portal-hyprland qt5-wayland qt6-wayland xorg-xhost nvidia-settings
yay -S --needed --noconfirm hyprshot

# eww
yay -S --needed --noconfirm eww

############################
### General Applications ###
############################

# thunar and plugins
sudo pacman -S --needed --noconfirm thunar thunar-media-tags-plugin tumbler
# thunar auto mount support
sudo pacman -S --needed --noconfirm thunar-volman gvfs gvfs-mtp gvfs-smb gvfs-gphoto2 udisks2
# xarchiver with thunar support (extract here functionality)
sudo pacman -S --needed --noconfirm thunar-archive-plugin xarchiver p7zip tar unrar unzip

# printing support
sudo pacman -S --needed --noconfirm cups cups-pdf ghostscript gutenprint foomatic-db-engine 
yay -S --needed --noconfirm epson-inkjet-printer-escpr

# scanning support
sudo pacman -S --needed --noconfirm simple-scan

# basic applications
sudo pacman -S --needed --noconfirm pavucontrol blueman bluez bluez-utils fastfetch htop ufw reflector

# Flatpak
sudo pacman -S --needed --noconfirm flatpak
flatpak install -y flathub com.github.tchx84.Flatseal 

#################################
### Post-installation cleanup ###
#################################
systemctl --user enable --now hyprpolkitagent.service
sudo systemctl enable --now cups.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now ufw.service
sudo ufw enable

