#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    dotnet-runtime \
    dotnet-sdk \
    mono-msbuild \
    mono-msbuild-sdkresolver \
    mono \
    aspnet-runtime

install_aur unityhub
