#!/usr/bin/env bash

# Prints uptime as: X days, Y hours, Z minutes

# /proc/uptime format: "<seconds> <idle_seconds>"
uptime_seconds=$(cut -d' ' -f1 /proc/uptime)
uptime_seconds=${uptime_seconds%.*}   # drop decimal part

udays=$(( uptime_seconds / 86400 ))
uhours=$(( (uptime_seconds % 86400) / 3600 ))
umins=$(( (uptime_seconds % 3600) / 60 ))

# printf "%d days, %d hours, %d minutes\n" "$udays" "$uhours" "$umins"

# Get birth time if supported, otherwise modification time of /
birth=$(stat -c %w / 2>/dev/null 2>/dev/null)
[ "$birth" = "-" ] || [ -z "$birth" ] && birth=$(stat -c %z /)

install_sec=$(date -d "$birth" +%s)
now_sec=$(date +%s)
elapsed_sec=$(( now_sec - install_sec ))

days=$(( elapsed_sec / 86400 ))

# If "sec" argument is given → detailed output
if [[ "$1" == "sec" ]]; then
    remaining=$(( elapsed_sec % 86400 ))
    hours=$(( remaining / 3600 ))
    remaining=$(( remaining % 3600 ))
    mins=$(( remaining / 60 ))
    secs=$(( remaining % 60 ))

    printf "%d days, %d hours, %d minutes, %d seconds\n" $days $hours $mins $secs
else
    # Default: only full days and uptime
    echo "$days"
fi

