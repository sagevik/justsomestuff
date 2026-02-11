#!/usr/bin/env bash

# mmsg -d disable_monitor,eDP-1
# mmsg -d disable_monitor,DP-5

# Get monitor names (first column of mmsg output)
mapfile -t monitors < <(mmsg -g -o | awk '{print $1}')

# Loop through monitors and enable each
for mon in "${monitors[@]}"; do
    echo "Disabling monitor: $mon"
    mmsg -d "disable_monitor,$mon"
done

