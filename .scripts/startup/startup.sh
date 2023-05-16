#!/bin/bash 

# Core components with dependancies.
(
    nvidia-force-comp-pipeline
    ~/.screenlayout/default_triple_monitor.sh
    feh --bg-fill ~/.wallpapers/Cloud_2_Nord.png &
    (
        picom -b 
        xborders -c ~/.config/picom/xborder.json
    ) &
    ~/.config/polybar/launch.sh
) &

# Services.
~/.config/cron/update_loadshedding.sh &
blueberry-tray &
dbus-launch dunst --config ~/.config/dunst/dunstrc &

# Remap caps lock to escape.
setxkbmap -option caps:none
xcape -e 'Caps_Lock=Escape'
xcape -e 'Caps=Escape'
