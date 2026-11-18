#!/bin/bash

# Define your folder pairs: "RemotePath LocalPath"
FOLDERS=(
    "gdrive-crypt:/Obsidian $HOME/gdrive/Obsidian"
    "gdrive:/Work/Notes $HOME/gdrive/Work/Notes"
)

# Common rclone arguments
# ARGS=(--compare size,modtime,checksum --check-access --slow-hash-sync-only)
ARGS=(--compare "size,modtime" --check-access)

# Detailed output only when run by hand; the systemd service logs to the journal.
if [ -t 1 ]; then
    ARGS+=(--verbose --progress)
fi

# --resync seeds bisync's state on first use. --check-access needs the
# RCLONE_TEST marker on both sides, so create it before the first run.
RESYNC=false
if [ "${1:-}" = "--resync" ]; then
    RESYNC=true
    ARGS+=(--resync)
fi

if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "No internet connection. Skipping sync."
    exit 0
fi

for entry in "${FOLDERS[@]}"; do
    # Split the entry into remote and local parts
    read -r REMOTE LOCAL <<<"$entry"

    if [ "$RESYNC" = true ]; then
        mkdir -p "$LOCAL"
        touch "$LOCAL/RCLONE_TEST"
        /usr/bin/rclone touch "$REMOTE/RCLONE_TEST"
    fi

    echo "Syncing $REMOTE to $LOCAL..."
    /usr/bin/rclone bisync "$REMOTE" "$LOCAL" "${ARGS[@]}"
done
