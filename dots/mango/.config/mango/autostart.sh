start_portals() {
  sleep 0.5 && /usr/lib/xdg-desktop-portal-wlr &
  sleep 1 && /usr/lib/xdg-desktop-portal &
}

wlr-randr --output "eDP-1" --on --mode 3840x2400 --pos 0,0 --scale 2

# waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css &
# swaybg -i ~/pix/wallpapers/.current -m fill &
# swaync &
# nm-applet &
# blueman-applet &
# xrdb -merge /home/rs/.Xresources &
# /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# foot --server &
#
# dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
# # The next line of command is not necessary. It is only to avoid some situations where it cannot start automatically
# start_portals &
#
