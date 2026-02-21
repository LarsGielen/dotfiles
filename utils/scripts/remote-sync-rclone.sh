#!/bin/bash

# Define your folder pairs: "RemotePath LocalPath"
FOLDERS=(
    "gdrive-crypt:/Obsidian $HOME/gdrive/Obsidian"
    "gdrive:/Work/Notes $HOME/gdrive/Work/Notes"
)

# Common rclone arguments
# ARGS="--compare size,modtime,checksum --check-access --slow-hash-sync-only"
ARGS="--compare size,modtime --check-access"

if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo "No internet connection. Skipping sync."
    exit 0
fi

for entry in "${FOLDERS[@]}"; do
    # Split the entry into remote and local parts
    read -r REMOTE LOCAL <<< "$entry"
    
    echo "Syncing $REMOTE to $LOCAL..."
    /usr/bin/rclone bisync $REMOTE $LOCAL $ARGS
done