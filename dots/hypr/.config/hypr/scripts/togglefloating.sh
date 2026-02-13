#!/bin/sh

USE_DIVIDER="$1"

# Get active window information
ACTIVE_WINDOW=$(hyprctl activewindow)
ACTIVE_WIN_ID=$(echo "$ACTIVE_WINDOW" | grep "Window" | awk '{print $2}')
IS_FLOATING=$(echo "$ACTIVE_WINDOW" | grep "floating" | awk '{print $2}')
MONITOR_ID=$(echo "$ACTIVE_WINDOW" | grep "monitor" | awk '{print $2}')

if [ "$IS_FLOATING" = "1" ]; then
    hyprctl dispatch centerwindow
    exit
fi

# Get monitor width and height using jq (optimized single call)
# read -r WIDTH HEIGHT <<< $(hyprctl monitors -j | jq -r ".[] | select(.id == $MONITOR_ID) | .width, .height")
WIDTH=$(hyprctl monitors -j | jq ".[] | select(.id == $MONITOR_ID) | .width")
HEIGHT=$(hyprctl monitors -j | jq ".[] | select(.id == $MONITOR_ID) | .height")


# Check if variables were successfully retrieved
if [ -z "$WIDTH" ] || [ -z "$HEIGHT" ] || [ -z "$MONITOR_ID" ]; then
    echo "Error: Could not retrieve monitor information for monitor ID $MONITOR_ID"
    exit 1
fi
if [ -z "$ACTIVE_WINDOW" ]; then
    echo "Error: No active window found"
    exit 1
fi

# Account for gaps_out and border_size
GAPS_OUT=2
BORDER_SIZE=2
WAYBAR_HEIGHT=20

if [ "$USE_DIVIDER" = "true" ]; then
    SELECTION=$(echo -e "Half\nThree Quarter\n4" | rofi -dmenu -i -p "Choose size")
    case $SELECTION in
        "Half")
            NEW_WIDTH=$(((WIDTH - 2 * GAPS_OUT - 2 * BORDER_SIZE) / 2))
            ;;
        "Three Quarter")
            NEW_WIDTH=$((((WIDTH - 2 * GAPS_OUT - 2 * BORDER_SIZE) / 4) * 3))
            ;;
        "4")
            NEW_WIDTH=$(((WIDTH - 2 * GAPS_OUT - 2 * BORDER_SIZE) / 4))
            ;;
    esac
    # WIDTH_DIVIDER=$(echo -e "2\n3\n4" | rofi -dmenu -p "divisor")
else
    # WIDTH_DIVIDER=2
    NEW_WIDTH=$(((WIDTH - 2 * GAPS_OUT - 2 * BORDER_SIZE) / 2))
fi
# Calculate 1/3 of monitor width, adjusted for gaps and borders
# NEW_WIDTH=$(((WIDTH - 2 * GAPS_OUT - 2 * BORDER_SIZE) / "$WIDTH_DIVIDER"))
# NEW_WIDTH=$(((WIDTH - 2 * GAPS_OUT - 2 * BORDER_SIZE) / 3))
NEW_HEIGHT=$((HEIGHT - WAYBAR_HEIGHT - 2 * GAPS_OUT - 2 * BORDER_SIZE))

# Calculate X-coordinate to center the window horizontally, accounting for gaps
X_POS=$((GAPS_OUT + (WIDTH - NEW_WIDTH - 2 * GAPS_OUT - 2 * BORDER_SIZE) / 2))
Y_POS=$((WAYBAR_HEIGHT + GAPS_OUT))  # Start below Waybar with gap

# If the window is not floating, toggle floating, resize, and position
if [ "$IS_FLOATING" = "0" ]; then
    echo "Toggling window to floating, resizing to 1/3 width, and positioning"
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact "$NEW_WIDTH" "$NEW_HEIGHT"
    hyprctl dispatch centerwindow
    # hyprctl dispatch moveactive "$X_POS" "$Y_POS"
    hyprctl dispatch moveactive 0 10
fi
