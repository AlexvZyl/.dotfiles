#!/bin/bash 

# Core components (order is important!)
(
    nvidia-force-comp-pipeline
    ~/.screenlayout/default_double_monitor.sh
    feh --bg-fill ~/.wallpapers/Space_Spiral_Nord.png &
    (
        picom -b 
        xborders -c ~/.config/picom/xborder.json
    ) &
    ~/.config/polybar/launch.sh
) &

# Services
~/.config/cron/update_loadshedding.sh &
dbus-launch dunst --config ~/.config/dunst/dunstrc &
~/.config/tmux/utils/start_all_servers.sh &

# Keyboard stuff
setxkbmap -option caps:escape &
xset r rate 175 40
