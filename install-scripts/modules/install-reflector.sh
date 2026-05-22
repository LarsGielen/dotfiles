#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages reflector

# run_cmd sudo systemctl enable reflector.service
