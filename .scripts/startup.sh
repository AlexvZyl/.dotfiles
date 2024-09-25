#!/bin/bash

# TODO: Try to move all of this to nix.

# Core components (order is important!)
(
    ~/.scripts/screenlayout/box_double_monitor.sh
    feh --bg-fill ~/.wallpapers/stay_by_aenami_dbnb1k3.png
    picom -b
    ~/.config/polybar/launch.sh
    nice -n 19 betterlockscreen -u "$HOME/.wallpapers/Gruvbox_Forest_Mountain.png" --display 1 &
) &

# Services
~/.config/tmux/utils/start_all_servers.sh &
dbus-launch dunst --config ~/.config/dunst/dunstrc &

# Apps
xdg-settings set default-web-browser zen
"$HOME/.scripts/utils/setup_keyboard.sh"

# TODO: This is probably not necessary
nmcli device disconnect wlp0s20f0u10
