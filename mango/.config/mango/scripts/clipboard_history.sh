#!/bin/sh

font="Hack Bold 16"

selection=$(cliphist list | wmenu -f "$font" -i -c -l 10 -p "Clipboard History: " | cliphist decode)
[ -z "$selection" ] && exit 0

printf '%s' "$selection" | wl-copy -n
notify-send "Clipboard History" "$selection"
