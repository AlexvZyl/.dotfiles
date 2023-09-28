#!/bin/bash 

# Core components (order is important!)
(
    nvidia-force-comp-pipeline
    ~/.screenlayout/default_double_monitor.sh
    # feh --bg-fill ~/.wallpapers/Space_Spiral_Nord.png &
    feh --bg-fill ~/.wallpapers/alena-aenami-horizon-1k_upscaled.jpg
    picom -b 
    ~/.config/polybar/launch.sh
) &

# Services
~/.config/cron/update_loadshedding.sh &
~/.config/tmux/utils/start_all_servers.sh &
dbus-launch dunst --config ~/.config/dunst/dunstrc &

# Keyboard stuff
setxkbmap -option caps:escape
xset r rate 165 50
