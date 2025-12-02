#!/bin/bash

# Attempt to reload Waybar configuration
if pgrep -x "waybar" > /dev/null; then
    pkill -SIGUSR2 waybar
else
    uwsm app -s b -- waybar
fi
