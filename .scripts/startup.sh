#!/bin/bash


# TODO: Try to move all of this to nix.

# Core components (order is important!)
(
    ~/.scripts/screenlayout/single_1080p_monitor.sh
    feh --bg-fill ~/.wallpapers/alena-aenami-quiet-1px.jpg
    picom -b
    ~/.config/polybar/launch.sh
) &

# Services
~/.config/tmux/utils/start_all_servers.sh &
dbus-launch dunst --config ~/.config/dunst/dunstrc &

# Apps
# xdg-settings set default-web-browser zen
"$HOME/.scripts/utils/setup_keyboard.sh"
