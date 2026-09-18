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

# The installer drops a bare `unity` binary into ~/.local/bin.
if command -v unity >/dev/null 2>&1; then
    ok "unity cli already installed"
else
    info "Installing the unity cli..."
    UNITY_CLI_CHANNEL=beta run_remote_installer https://public-cdn.cloud.unity3d.com/hub/prod/cli/install.sh
    ok "unity cli installed"
fi

# Todo: In future we could install a unity version right away, and unityhub can be removed if I do all hub work via the terminial, which would be cool.
