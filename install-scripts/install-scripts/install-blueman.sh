#!/bin/bash

sudo pacman -S --needed --noconfirm \
    blueman \
    bluez \
    bluez-utils

sudo systemctl enable --now bluetooth.service
