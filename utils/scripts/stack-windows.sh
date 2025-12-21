#!/usr/bin/env bash
# Usage: ./stack-windows.sh <workspace-id> <width_px> <height_px>

set -eo pipefail

WS="$1"

if [ -z "$WS" ]; then
  echo "Usage: $0 <workspace-id>"
  exit 1
fi

PAD_X=12
PAD_Y_TOP=40
PAD_Y_BOTTOM=110
PAD_Y_BETWEEN=12

clients_json="$(hyprctl clients -j)"

# address|floating|monitor
mapfile -t CLIENTS < <(
  jq -r --argjson wsid "$WS" '
    .[] 
    | select(.workspace.id == ($wsid|tonumber)) 
    | "\(.address)|\(.floating)|\(.monitor)"
  ' <<<"$clients_json"
)

if [ "${#CLIENTS[@]}" -eq 0 ]; then
  echo "No windows on workspace $WS"
  exit 0
fi

echo "Stacking ${#CLIENTS[@]} windows on workspace $WS..."

# pick monitor of first window
IFS='|' read -r FIRST_ADDR _ FIRST_MON <<<"${CLIENTS[0]}"

monitors_json="$(hyprctl monitors -j)"

# get monitor top-left using .x and .y (Hyprland dropped .at[])
MON_X=$(jq -r --argjson id "$FIRST_MON" '
  .[] | select(.id == ($id|tonumber)) | .x
' <<<"$monitors_json")

MON_Y=$(jq -r --argjson id "$FIRST_MON" '
  .[] | select(.id == ($id|tonumber)) | .y
' <<<"$monitors_json")

# get monitor size (width and height)
MON_W=$(jq -r --argjson id "$FIRST_MON" '
  .[] | select(.id == ($id|tonumber)) | .width
' <<<"$monitors_json")

MON_H=$(jq -r --argjson id "$FIRST_MON" '
  .[] | select(.id == ($id|tonumber)) | .height
' <<<"$monitors_json")

WIN_W=$(( MON_H - 2 * PAD_X ))
WIN_H=$(( (MON_W - PAD_Y_TOP - PAD_Y_BOTTOM - (PAD_Y_BETWEEN * (${#CLIENTS[@]} - 1))) / ${#CLIENTS[@]} ))

echo "Monitor size: ${MON_W}x${MON_H}, Window size: ${WIN_W}x${WIN_H}"

# # fallback safety
# [ "$MON_X" = "null" ] && MON_X=0
# [ "$MON_Y" = "null" ] && MON_Y=0

echo "Using monitor $FIRST_MON at ($MON_X,$MON_Y)"

Y_OFFSET=$PAD_Y_TOP

for item in "${CLIENTS[@]}"; do
  IFS='|' read -r ADDR FLOATED MON <<<"$item"
  ADDR_SPEC="address:${ADDR}"

  # float if necessary
  if [ "$FLOATED" = "false" ]; then
    hyprctl dispatch togglefloating "$ADDR_SPEC"
    sleep 0.01
  fi

  # resize
  hyprctl dispatch resizewindowpixel exact "$WIN_W" "$WIN_H","$ADDR_SPEC"
  sleep 0.01

  # place
  TARGET_X=$(( MON_X + PAD_X ))
  TARGET_Y=$(( MON_Y + Y_OFFSET ))

  hyprctl dispatch movewindowpixel exact "$TARGET_X" "$TARGET_Y","$ADDR_SPEC"
  sleep 0.01

  Y_OFFSET=$(( Y_OFFSET + WIN_H + PAD_Y_BETWEEN ))
done
