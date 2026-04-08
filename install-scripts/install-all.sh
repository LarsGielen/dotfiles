#!/bin/bash

ORIGINAL_DIR=$(pwd)
REPO_NAME="dotfiles"

cd ~/$REPO_NAME/install-scripts || exit 1

# shellcheck disable=SC1090
for script in ./install-scripts/install-*.sh; do
    . "$script"
done

cd "$ORIGINAL_DIR" || exit 1