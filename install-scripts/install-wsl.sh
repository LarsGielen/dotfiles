#!/bin/bash

ORIGINAL_DIR=$(pwd)

cd ~/dotfiles/install-scripts || exit 1

# Base system utilities
. ./install-scripts/install-stow.sh
. ./install-scripts/install-git.sh

# Environment
. ./install-wsl-dotfiles.sh

# Drivers and helpers
. ./install-scripts/install-yay.sh

# Shell and shell utilities
. ./install-scripts/install-zsh.sh

# System utilities
. ./install-scripts/install-reflector.sh
. ./install-scripts/install-nano.sh

# File manager
. ./install-scripts/install-yazi.sh

# Development tools
. ./install-scripts/install-python.sh

cd "$ORIGINAL_DIR" || exit 1