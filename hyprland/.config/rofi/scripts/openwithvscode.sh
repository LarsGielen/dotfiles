#!/bin/bash

VSCODE_STORAGE_PATH="$HOME/.config/VSCodium/User/globalStorage/storage.json"

if [ ! -f "$VSCODE_STORAGE_PATH" ]; then
    echo "VS Code storage.json file not found at $VSCODE_STORAGE_PATH."
    exit 1
fi

recent_folders=$(jq -r '.lastKnownMenubarData.menus.File.items.[] | select(.id == "submenuitem.MenubarRecentMenu").submenu.items.[] | select(.id == "openRecentFolder").uri.path' "$VSCODE_STORAGE_PATH")
recent_files=$(jq -r '.lastKnownMenubarData.menus.File.items.[] | select(.id == "submenuitem.MenubarRecentMenu").submenu.items.[] | select(.id == "openRecentFile").uri.path' "$VSCODE_STORAGE_PATH")

recent_folders=$(echo "$recent_folders" | sed "s|$HOME/|~/|g")
recent_files=$(echo "$recent_files" | sed "s|$HOME/|~/|g")

folder_icon=""
file_icon=""
menu_items=""
while IFS= read -r folder; do
    menu_items+="${folder}/\0icon\x1f<span color='white'>${folder_icon}</span>\n"
done <<< "$recent_folders"

while IFS= read -r folder; do
    menu_items+="${folder}\0icon\x1f<span color='white'>${file_icon}</span>\n"
done <<< "$recent_files"

if [ $# -eq 0 ]; then
    echo -e "$menu_items"
fi

if [ $# -eq 1 ]; then
    expanded_path=$(eval echo $1)
    codium "$expanded_path"
fi

done