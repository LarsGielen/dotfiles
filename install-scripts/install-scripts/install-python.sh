#!/bin/bash

echo "Installing python..."
sudo pacman -S --needed --noconfirm base-devel openssl zlib xz tk pyenv
yay -S --needed --noconfirm pyenv-virtualenv
pyenv install 3.12.11 --skip-existing