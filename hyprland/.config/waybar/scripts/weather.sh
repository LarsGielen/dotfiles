#!/bin/sh

# 1 to get temperature
# 2 to get icon

location="Pelt"
text="$(curl -s "https://wttr.in/$location?format=1" | sed 's/  */ /g')"
icon="$(echo $text | awk '{print substr($0, 1, 1)}')"
temperature="$(echo $text | sed 's/^..\(.*\)/\1/')"
tooltip="$(curl -s "https://wttr.in/$location?0T" |
    sed 's/\\/\\\\/g' |
    sed ':a;N;$!ba;s/\n/\\n/g' |
    sed 's/"/\\"/g')" 

if ! grep -q "Unknown location" <<< "$text"; then
if [ "$1" = "1" ]; then
cat << EOF
{"text": "$temperature", "tooltip": "<tt>$tooltip</tt>"}
EOF
elif [ "$1" = "2" ]; then
cat << EOF
{"text": "$icon", "tooltip": "<tt>$tooltip</tt>"}
EOF
else
echo '{"text": "Error", "tooltip": "Invalid argument. Use 1 for temperature or 2 for icon."}'
fi
else
echo '{"text": "Error", "tooltip": "Unknown location or data unavailable"}'
fi