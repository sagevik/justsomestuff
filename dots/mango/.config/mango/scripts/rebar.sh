#!/bin/bash

# toggle waybar
if pgrep -f waybar; then
    pkill waybar
else
    waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css &
fi

# restart waybar
# pkill waybar; waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css &
