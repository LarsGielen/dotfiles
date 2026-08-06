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

# install unity cli
run_quiet curl -fsSL https://public-cdn.cloud.unity3d.com/hub/prod/cli/install.sh | UNITY_CLI_CHANNEL=beta bash

# Todo: In future we could install a unity version right away, and unityhub can be removed if I do all hub work via the terminial, which would be cool.
