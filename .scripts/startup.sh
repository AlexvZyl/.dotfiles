#!/bin/bash

pkill polybar

# TODO: Try to move all of this to nix.

# Core components (order is important!)
(
    ~/.scripts/screenlayout/single_1440p.sh
    feh --bg-fill ~/.wallpapers/FALCON.jpg
    picom -b
    ~/.config/polybar/launch.sh
) &

# Services
~/.config/tmux/utils/start_all_servers.sh &
dbus-launch dunst --config ~/.config/dunst/dunstrc &
dunstctl set-paused true

# Apps
# xdg-settings set default-web-browser zen
"$HOME/.scripts/utils/setup_keyboard.sh"

unclutter --fork --start-hidden
