#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages \
    bash

stow_config bash ~/.bashrc ~/.bash_profile
