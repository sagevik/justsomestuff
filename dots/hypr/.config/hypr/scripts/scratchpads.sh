#! /bin/sh

declare -A applications
applications["Bitwarden"]="bitwarden"
applications["nvim_scratch"]="foot --title='nvim_scratch'"
applications["dd_foot"]="foot --title='dd_foot'"
applications["Volume Control"]="pavucontrol"

selected_application="$1"
workspace_hidden_application="$2"
echo "selected app: $selected_application"
echo "key value: ${applications[$selected_application]}"

# Get the window ID (address) for the application window
current_active_window=$(hyprctl activewindow | grep "Window" | awk '{print $2}')
window_id=$(hyprctl clients | grep "$selected_application" | grep "Window" | awk '{print $2}')

# Get the active workspace ID
active_workspace=$(hyprctl activeworkspace -j | jq '.id')
# Get the current workspace of the scratchpad window
current_workspace=$(hyprctl clients | grep -A 5 "$window_id" | grep workspace | awk '{print $2}')

echo "window_id: $window_id"
echo "active_workspace: $active_workspace"
echo "current_workspace: $current_workspace"

if [ -z "$window_id" ]; then
    # echo "<application> window not found, launching new instance..."
    # Launch <application> and move to active workspace
    hyprctl dispatch exec "${applications[$selected_application]}"
    exit 0
fi

# Check if the window is on the active workspace or special:scratchA
if [ "$current_workspace" = "$active_workspace" ]; then
    # Window is on active workspace, move to special:scratchA
    hyprctl dispatch focuswindow address:0x"$window_id"
    hyprctl dispatch movetoworkspacesilent "$workspace_hidden_application"
    # hyprctl dispatch movetoworkspacesilent special:scratchA
elif [ "$current_workspace" = "$workspace_hidden_application" ]; then
# elif [ "$current_workspace" = "special:scratchA" ]; then
    # Window is on special:scratchA, move to active workspace
    hyprctl dispatch focuswindow address:0x"$window_id"
    hyprctl dispatch movetoworkspacesilent $active_workspace
    hyprctl dispatch bringactivetotop
else
    # Window is on another workspace, move to active workspace
    hyprctl dispatch focuswindow address:0x"$window_id"
    hyprctl dispatch movetoworkspacesilent $active_workspace
    hyprctl dispatch focuswindow address:0x"$window_id"
    hyprctl dispatch bringactivetotop
fi
