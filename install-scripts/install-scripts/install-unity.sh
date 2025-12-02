#!/bin/bash

echo "Installing unity..."
sudo pacman -S --needed --noconfirm \
    dotnet-runtime \
    dotnet-sdk \
    mono-msbuild \
    mono-msbuild-sdkresolver \
    mono \
    aspnet-runtime
    
yay -S --needed --noconfirm unityhub