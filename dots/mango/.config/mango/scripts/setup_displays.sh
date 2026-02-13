#!/usr/bin/env bash
# set -euo pipefail

# This script:
# 1) Finds the external output(s) (non-eDP/LVDS/DSI) that are enabled.
# 2) For the first external output, picks its maximum resolution by pixel area.
# 3) Enables eDP at 3840x2400 on the left (0,0).
# 4) Places the external output immediately to the right (2400,0) at its max resolution.
#
# If you have multiple externals, it will configure the first one found.
# You can extend it to lay out more screens to the right if needed.

INTERNAL_RE='^(eDP|LVDS|DSI)'
MODE_INTERNAL="3840x2400"
SCALE_INTERNAL="2.0"

# Parse wlr-randr once
WR="$(wlr-randr)"

# Get the eDP output name (first matching eDP*). If none, we’ll still try "eDP-1".
edp_name="$(printf '%s\n' "$WR" | awk '/^[A-Za-z0-9.-]+ "/ {out=$1} out ~ /^eDP/ {print out; exit}')"
: "${edp_name:=eDP-1}"

# Find the first enabled external output and its max resolution (largest area)
read -r external_name external_max_res <<<"$(
  printf '%s\n' "$WR" | awk -v INTERNAL_RE="$INTERNAL_RE" '
    function flush() {
      if (out != "" && enabled == 1 && internal == 0 && best_res != "") {
        print out " " best_res;
      }
    }
    /^[A-Za-z0-9.-]+ "/ {
      flush();
      split($0, a, " ");
      out = a[1];
      enabled = 0;
      internal = (out ~ INTERNAL_RE) ? 1 : 0;
      in_modes = 0;
      best_area = 0;
      best_res = "";
      next;
    }
    $1 == "Enabled:" {
      enabled = ($2 == "yes") ? 1 : 0;
      next;
    }
    $1 == "Modes:" { in_modes = 1; next; }
    # Lines like: "  5120x1440 px, 69.973000 Hz ..."
    in_modes && /^[[:space:]]*[0-9]+x[0-9]+ px, [0-9.]+ Hz/ {
      match($0, /([0-9]+)x([0-9]+) px,/, mm);
      w = mm[1] + 0; h = mm[2] + 0;
      area = w * h;
      if (area > best_area) {
        best_area = area;
        best_res = w "x" h;
      }
      next;
    }
    END { flush(); }
  ' | head -n1
)"

if [[ -z "$external_name" || -z "$external_max_res" ]]; then
  echo "No enabled external outputs found. Will still enable ${edp_name} at 3840x2400 on the left."
  # notify-send "Display Layout" "No enabled external outputs found.\nWill still enable ${edp_name}: 3840x2400 at (0,0)"
  # Ensure eDP on at 3840x2400, positioned at 0,0
  wlr-randr --output "$edp_name" --on --mode "$MODE_INTERNAL" --pos 0,0 --scale "$SCALE_INTERNAL"
  exit 0
fi

echo "Detected external output: $external_name (max: $external_max_res)"
echo "Ensuring internal eDP output: $edp_name at 3840x2400 on the left."

# 1) Enable and place the eDP (internal) at 3840x2400 on the left
wlr-randr --output "$edp_name" --on --mode "$MODE_INTERNAL" --pos 0,0 --scale "$SCALE_INTERNAL"

# 2) Enable and place external to the right of eDP
#    Since eDP is 1920 wide, external goes at X=2400, Y=0
wlr-randr --output "$external_name" --on --mode "$external_max_res" --pos 1920,0

echo "Layout applied:"
echo "  ${edp_name}: 3840x2400 at (0,0)"
echo "  ${external_name}: ${external_max_res} at (1920,0)"

# notify-send "Display Layout" "INT:${edp_name}: 3840x2400 DPIs 2\nEXT:${external_name}: ${external_max_res} at (2400,0)"

