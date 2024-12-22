#!/bin/sh

location="Pelt"
text="$(curl -s "https://wttr.in/$location?format=1" | sed 's/  */ /g')"
tooltip="$(curl -s "https://wttr.in/$location?0QT" |
    sed '1s/$/ '"($location)"'/' |
    sed 's/\\/\\\\/g' |
    sed ':a;N;$!ba;s/\n/\\n/g' |
    sed 's/"/\\"/g')" 

if ! grep -q "Unknown location" <<< "$text"; then
cat << EOF
{"text": "$text", "tooltip": "<tt>$tooltip</tt>"}
EOF
fi
