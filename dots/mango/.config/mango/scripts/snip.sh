#! /bin/bash

time=$(date +%Y-%m-%d_%H-%M-%S)
file="$HOME/pix/screenshots/screenshot_$time.png"

choice=$(printf "Selection\nScreen" | wmenu -f "Hack Bold 16" -i -l 2 -c -p "Screenshot type")
echo "choice $choice"

case $choice in
  "Selection")
    grim -l 0 -g "$(slurp)" -s 1 $file
    notify-send "Screenshot" "$choice saved to $file"
    wl-copy < "$file"
    ;;
  "Screen")
    sleep 0.2
    grim -l 0 -s 1 $file
    notify-send "Screenshot" "$choice saved to $file"
    wl-copy < "$file"
    ;;
  "clipboard")
    grim -l 0 -g "$(slurp)" -s 1 - | wl-copy
    notify-send "Screenshot" "put to $choice"
    ;;
  *)
    ;;
esac
