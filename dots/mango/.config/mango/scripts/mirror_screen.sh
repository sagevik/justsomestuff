#!/bin/sh

font="Hack Bold 24"

check_external_monitor() {
    external_count=$(
        wlr-randr --json |
        jq '[.[] | select(.enabled==true and (.name | startswith("eDP") | not))] | length'
    )

    if [ "$external_count" -eq 0 ]; then
        notify-send "Display" "No external monitor connected"
        exit 0
    fi

    return 0
}

mirror_screen() {
    wl-mirror eDP-1 &
    sleep 0.5
    mmsg -d tagmon,left
    mmsg -d tag,1
    mmsg -d comboview,1
    mmsg -d togglefullscreen
    mmsg -d focusmon,left
}

select_and_set_output_mode() {
  # get external monitor name (first non-eDP enabled output)
  output=$(
    wlr-randr --json |
    jq -r '.[] | select(.enabled==true and (.name | startswith("eDP") | not)) | .name' |
    head -n1
  )

  # abort if none found
  [ -z "$output" ] && exit 1

  # get available modes and choose via wmenu
  modes_list=$(
    wlr-randr --json |
    jq -r --arg out "$output" '
      .[] | select(.name==$out) | .modes[] |
      "\(.width)x\(.height)"
    ' |
    sort -t x -k1,1nr -k2,2nr -u
  )

  # prepend CURRENT
  modes_list="CURRENT"$'\n'"$modes_list"

  # show in wmenu
  mode=$(echo "$modes_list" | wmenu -f "$font" -i -c -l 10 -p "Mode for $output:")

  [ -z "$mode" ] && exit 0

  # if CURRENT selected → do nothing
  [ "$mode" = "CURRENT" ] && return 0

  # apply if selected
  [ -n "$mode" ] && wlr-randr --output "$output" --mode "$mode"
}

check_external_monitor

if pgrep -f "wl-mirror" >/dev/null; then
    option=$(echo -e "Stop mirroring" | wmenu -f "$font" -c -l 1 -p "?")
    case $option in
      "Stop mirroring")
          pkill wl-mirror
          ;;
      *)
        exit 0
        ;;
    esac
else
  select_and_set_output_mode

  mirror_screen
fi
