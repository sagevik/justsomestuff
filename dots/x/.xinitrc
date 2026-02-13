#!/bin/sh

# Keyboard layout
setxkbmap no

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Screen resolution
xrandr --output eDP-1 --primary --mode 1920x1200 --pos 0x0 --rotate normal &

# Compositor
picom --config $HOME/.config/picom/picom.conf &

# Statusbar
slstatus &

# wallpaper
xwallpaper --zoom $HOME/.local/share/background/wp.png

# Updates
archupdate -b &

# Systray
nm-applet &
blueman-applet &

# Polkit
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# Volume in statusbar
volume init &

# Restart loop
while true; do
    dwm >/dev/null 2>&1
done

# Execute dwm
exec dwm

