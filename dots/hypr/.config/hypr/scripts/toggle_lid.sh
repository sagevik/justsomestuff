#!/bin/bash

sleep 0.5

# Check lid state
LID_STATE=$(cat /proc/acpi/button/lid/LID/state | awk '{print $2}')

# Get external monitor name
EXTERNAL_MONITOR=$(hyprctl monitors | grep -v "eDP-1" | grep "Monitor" | awk '{print $2}' | head -n 1)

if [ "$LID_STATE" = "closed" ]; then
    # Disable laptop monitor and move all workspaces to external monitor
    hyprctl keyword monitor "eDP-1,disable"
    for ws in $(hyprctl workspaces -j | jq -r '.[] | .id'); do
        hyprctl dispatch moveworkspacetomonitor "$ws" "$EXTERNAL_MONITOR"
    done
else
    # Re-enable laptop monitor
    hyprctl keyword monitor "eDP-1,1920x1080@59.95,0x0,1.0"
fi

