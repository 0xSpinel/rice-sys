#!/bin/bash

export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=VXWM
export DESKTOP_SESSION=vxwm

# Import into systemd and D-Bus
systemctl --user import-environment \
    DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP DESKTOP_SESSION
dbus-update-activation-environment --systemd \
    DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP DESKTOP_SESSION

# ----------------------------
# DISPLAY / BASIC SETUP
# ----------------------------
xrandr --auto
xset r rate 250 40 &
xinput set-prop 10 "libinput Natural Scrolling Enabled" 1 &
# ----------------------------
# WALLPAPER
# ----------------------------
feh --bg-scale ~/Media/random\ shit\ pictures/boat.jpg &

# ----------------------------
# COMPOSITOR
# ----------------------------
(sleep 1 && vcompmgr) &

xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr

# ----------------------------
# KEYBINDS
# ----------------------------
sxhkd &

# ----------------------------
# STATUS BAR (xsetroot)
# ----------------------------
while true; do
    # Power profile (AC -> performance, battery -> power-saver)
    ac=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null)
    prof=$(powerprofilesctl get 2>/dev/null)
    if [ "$ac" = "1" ] && [ "$prof" != "performance" ]; then
        powerprofilesctl set performance
    elif [ "$ac" != "1" ] && [ "$prof" != "power-saver" ]; then
        powerprofilesctl set power-saver
    fi

done &
libinput-gestures &
exec vxwm
