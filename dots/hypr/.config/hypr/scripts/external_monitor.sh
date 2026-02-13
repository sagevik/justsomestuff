#!/bin/sh

OUT="/tmp/external_monitor_hyprlock.conf"

name=$(wlr-randr --json | jq -r ' .[] | select(.name != "eDP-1") | select(.enabled == true) | .name ')

content="\$external_monitor = $name"

# if file exists and content is identical → do nothing
if [ -f "$OUT" ]; then
    current_content=$(cat "$OUT")
    if [ "$current_content" = "$content" ]; then
        exit 0
    fi
fi

# otherwise write/update file
printf '%s\n' "$content" > "$OUT"

# printf '$external_monitor = %s\n' "$name" > "$OUT"

