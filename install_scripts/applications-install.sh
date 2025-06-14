#!/bin/bash

# Gaming
sudo pacman -S --needed --noconfirm steam gamemode gamescope vivaldi obs-studio
flatpak install -y bottles

# Musescore
flatpak install -y flathub org.musescore.MuseScore

# General Applications
sudo pacman -S --needed --noconfirm gimp
flatpak install -y flathub md.obsidian.Obsidian 
flatpak install -y flathub com.discordapp.Discord

sudo usermod -aG gamemode $USER