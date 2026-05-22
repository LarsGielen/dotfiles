#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

install_packages base-devel openssl zlib xz tk pyenv
install_aur pyenv-virtualenv

info "Installing Python 3.12.11 via pyenv..."
run_quiet pyenv install 3.12.11 --skip-existing
ok "Python 3.12.11 ready"
