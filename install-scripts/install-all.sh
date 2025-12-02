#!/bin/bash

ORIGINAL_DIR=$(pwd)

cd ~/dotfiles/install-scripts || exit 1

. ./install-scripts/install-stow.sh
. ./install-scripts/install-git.sh

. ./install-scripts/install-dotfiles.sh
. ./install-scripts/install-hyprland.sh

. ./install-scripts/install-drivers.sh
. ./install-scripts/install-yay.sh

. ./install-scripts/install-ufw.sh
. ./install-scripts/install-mandb.sh
. ./install-scripts/install-reflector.sh
. ./install-scripts/install-htop.sh
. ./install-scripts/install-nano.sh
. ./install-scripts/install-blueman.sh

. ./install-scripts/install-docker.sh
. ./install-scripts/install-python.sh
. ./install-scripts/install-nodejs.sh

. ./install-scripts/installl-thunar.sh

. ./install-scripts/install-flatpak.sh

. ./install-scripts/install-vscode.sh
. ./install-scripts/install-blender.sh
. ./install-scripts/install-obs.sh
. ./install-scripts/install-vivaldi.sh
. ./install-scripts/install-godot.sh
. ./install-scripts/install-unity.sh
. ./install-scripts/install-zotero.sh

. ./install-scripts/install-gaming.sh

cd "$ORIGINAL_DIR" || exit 1