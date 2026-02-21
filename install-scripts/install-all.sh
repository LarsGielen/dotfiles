#!/bin/bash

ORIGINAL_DIR=$(pwd)

cd ~/dotfiles/install-scripts || exit 1

# Base system utilities
. ./install-scripts/install-stow.sh
. ./install-scripts/install-git.sh

# Desktop environment
. ./install-dotfiles.sh
. ./install-scripts/install-hyprland.sh
. ./install-scripts/install-eww.sh
. ./install-scripts/install-waybar.sh
. ./install-scripts/install-notifications.sh

. ./install-scripts/install-keyboard.sh

# Drivers and helpers
# . ./install-scripts/install-drivers.sh
. ./install-scripts/install-yay.sh

# Shell and shell utilities
. ./install-scripts/install-starship.sh
. ./install-scripts/install-zsh.sh

# System utilities
. ./install-scripts/install-ufw.sh
. ./install-scripts/install-mandb.sh
. ./install-scripts/install-reflector.sh
. ./install-scripts/install-htop.sh
. ./install-scripts/install-nano.sh
. ./install-scripts/install-blueman.sh
. ./install-scripts/install-audio.sh
. ./install-scripts/install-snapper.sh
. ./install-scripts/install-rclone.sh

# Video and image tools
. ./install-scripts/install-video.sh

# File manager
. ./install-scripts/install-thunar.sh
. ./install-scripts/install-yazi.sh

# Development tools
. ./install-scripts/install-docker.sh
. ./install-scripts/install-python.sh
. ./install-scripts/install-vscode.sh
. ./install-scripts/install-blender.sh
. ./install-scripts/install-unity.sh
. ./install-scripts/install-godot.sh
. ./install-scripts/install-zotero.sh
. ./install-scripts/install-gimp.sh

# Productivity
. ./install-scripts/install-flatpak.sh
. ./install-scripts/install-obs.sh
. ./install-scripts/install-vivaldi.sh

# Gaming
. ./install-scripts/install-gaming.sh

# Communication tools
. ./install-scripts/install-slack.sh

cd "$ORIGINAL_DIR" || exit 1