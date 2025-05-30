#!/bin/bash

# Paths
INPUT="$HOME/.config/colors/colors.txt"
CSS_OUT="$HOME/.config/colors/colors.css"
CONF_OUT="$HOME/.config/colors/colors.conf"

# Create or overwrite output files
echo "/* Generated colors.css */" > "$CSS_OUT"
echo "# Generated colors.conf" > "$CONF_OUT"

hex_to_rgba() {
    hex=${1#"#"}
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    echo "rgba($r,$g,$b,1.0)"
}

# Parse input
while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Only process lines like: @export name #hex;
    if [[ $line =~ @export[[:space:]]+([a-zA-Z0-9_]+)[[:space:]]+(#[a-fA-F0-9]{6})\; ]]; then
        name="${BASH_REMATCH[1]}"
        hex="${BASH_REMATCH[2]}"

        # Write to CSS
        echo "@define-color $name $hex;" >> "$CSS_OUT"

        # Write to Hyprland config
        rgba_val=$(hex_to_rgba "$hex")
        echo "\$$name = $rgba_val" >> "$CONF_OUT"
    fi
done < "$INPUT"