#!/bin/bash

sudo pacman -S --needed --noconfirm \
    steam \
    gamemode \
    gamescope \
    mangohud

sudo usermod -aG gamemode $USER