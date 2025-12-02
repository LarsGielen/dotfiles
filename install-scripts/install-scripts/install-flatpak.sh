#!/bin/bash

echo "Installing flatpak..."
sudo pacman -S --needed --noconfirm flatpak
flatpak install -y flathub com.github.tchx84.Flatseal 
flatpak install -y bottles
flatpak install -y flathub org.musescore.MuseScore
flatpak install -y flathub md.obsidian.Obsidian 
flatpak install -y flathub com.discordapp.Discord
