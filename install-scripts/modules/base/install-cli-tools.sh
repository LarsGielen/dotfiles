#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/common.sh"

# Small command-line tools with no config or service of their own.
install_packages \
    htop \
    jq \
    nano \
    man-db
