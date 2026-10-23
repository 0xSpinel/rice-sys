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
feh --bg-scale ~/Media/random\ shit\ pictures/candle.jpg &

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

    # Time
    time=$(date '+%I:%M %p')
    today=$(date '+%a %d %b')

    # CPU
    read _ user nice system idle iowait irq softirq steal _ _ < /proc/stat
    total1=$((user+nice+system+idle+iowait+irq+softirq+steal))
    idle1=$((idle+iowait))

    sleep 1

    read _ user nice system idle iowait irq softirq steal _ _ < /proc/stat
    total2=$((user+nice+system+idle+iowait+irq+softirq+steal))
    idle2=$((idle+iowait))

    total=$((total2-total1))
    idle=$((idle2-idle1))
    cpu=$((100 * (total-idle) / total))

    # RAM
    mem=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

    # Network
    iface=$(ip route | awk '/default/ {print $5; exit}')

    rx1=$(cat /sys/class/net/$iface/statistics/rx_bytes)
    tx1=$(cat /sys/class/net/$iface/statistics/tx_bytes)

    sleep 1

    rx2=$(cat /sys/class/net/$iface/statistics/rx_bytes)
    tx2=$(cat /sys/class/net/$iface/statistics/tx_bytes)

    down=$(numfmt --to=iec $((rx2-rx1)))
    up=$(numfmt --to=iec $((tx2-tx1)))

    # Battery
    battery=$(find /sys/class/power_supply -maxdepth 1 -name "BAT*" | head -n1)

    if [ -n "$battery" ]; then
       bat=$(cat "$battery/capacity")
       stat=$(cat "$battery/status")

       case "$stat" in
           Charging)    batt="⚡ ${bat}%" ;;
           Full)        batt="${bat}%" ;;
           Discharging) batt="${bat}%" ;;
           *)           batt="${bat}%" ;;
         esac
     else
         batt="No Battery"
     fi
    # Disk usage (root)
    disk=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    xsetroot -name "↓${down}/s ↑${up}/s | ${cpu}% | ${mem} | ${batt} | ${disk} | ${time} | ${today}"

    sleep 3
done &
libinput-gestures &
exec vxwm
