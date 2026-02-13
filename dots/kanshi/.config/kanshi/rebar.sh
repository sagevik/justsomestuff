#!/bin/sh

# restart waybar
pkill waybar; waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css &
