#!/usr/bin/env bash

# mmsg -d enable_monitor,eDP-1
# mmsg -d enable_monitor,DP-5

# Get monitor names (first column of mmsg output)
mapfile -t monitors < <(mmsg -g -o | awk '{print $1}')

# Loop through monitors and enable each
for mon in "${monitors[@]}"; do
    echo "Enabling monitor: $mon"
    mmsg -d "enable_monitor,$mon"
done
sleep 1

# restore monitor setup
$HOME/.config/mango/scripts/setup_displays.sh
