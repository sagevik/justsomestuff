#!/bin/sh

# Start or activate Bitwarden
mmsg -d toggle_named_scratchpad,Bitwarden,none,bitwarden-desktop

sleep 0.2

# check if bitwarden currently focused
if mmsg -g -c | grep -qi bitwarden; then
    # currently visible → pause wl-paste while bitwarden is active
    pkill -STOP wl-paste 2>/dev/null
    notify-send -t 1500 "Clipboard" "Paused"
else
    # currently hidden → clear clipboard and resume wl-paste
    sleep 3
    wl-copy --clear
    sleep 1
    pkill -CONT wl-paste 2>/dev/null
    notify-send -t 1500 "Clipboard" "Resumed"
fi

