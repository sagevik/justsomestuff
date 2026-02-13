#!/bin/sh

font="Hack Bold 16"

declare -A profiles=(
    ["Auto"]="Auto"
    ["38 only"]="38 only"
    ["38 dual"]="38 dual"
    ["49 only"]="49 only"
    ["49 dual"]="49 dual"
    ["Integrated"]="Integrated"
    ["Manual"]="Manual"
)

build_menu() {
    printf '%s\n' "Auto"
    for key in "${!profiles[@]}"; do
      [ "$key" != "Auto" ] && printf '%s\n' "$key"
    done | sort
}

option=$(build_menu | wmenu -f "$font" -c -i -l "${#profiles[@]}" -p "Display Setup")

rebar() {
  pkill waybar; waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css &
}

case $option in
    "Auto")
        ~/.config/mango/scripts/./setup_displays.sh
        rebar
        ;;
    "38 only")
        wlr-randr --output DP-3 --on --output eDP-1 --off
        wlr-randr --output DP-3 --mode 3840x1600
        rebar
        ;;
    "38 dual")
        wlr-randr --output DP-3 --on
        wlr-randr --output eDP-1 --on
        wlr-randr --output DP-3 --mode 3840x1600 --right-of eDP-1 --output eDP-1 --mode 3840x2400
        rebar
        ;;
    "49 only")
        wlr-randr --output DP-4 --on --output eDP-1 --off
        wlr-randr --output DP-4 --mode 5120x1440
        rebar
        ;;
    "49 dual")
        wlr-randr --output DP-4 --on
        wlr-randr --output eDP-1 --on
        wlr-randr --output DP-4 --mode 5120x1440 --right-of eDP-1 --output eDP-1 --mode 3840x2400
        rebar
        ;;
    "Integrated")
        wlr-randr --output eDP-1 --on
        wlr-randr --output eDP-1 --mode 3840x2400 --output DP-4 --off
        rebar
        ;;
    "Manual")
        wdisplays
        rebar
        ;;
    *)
        exit
        ;;
esac
