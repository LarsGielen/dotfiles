#!/bin/bash

# Get the list of connected monitors
MONITORS=$(hyprctl monitors | grep "Monitor" | wc -l)

if [ "$MONITORS" -gt 1 ]; then
    # External monitor is connected
    cp ~/.config/hypr/conf/monitor_setups/home.conf ~/.config/hypr/conf/monitor.conf
else
    # Laptop-only mode
    cp ~/.config/hypr/conf/monitor_setups/laptop.conf ~/.config/hypr/conf/monitor.conf
fi

# Reload Hyprland to apply the new configuration
hyprctl reload
