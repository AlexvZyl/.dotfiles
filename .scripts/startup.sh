#!/bin/bash

# TODO: Try to move all of this to nix.

# Core components (order is important!)
(
    #~/.screenlayout/default_double_monitor.sh
    ~/.screenlayout/box_double_monitor.sh
    #feh --bg-fill ~/.wallpapers/Space_Spiral_Nord.png &
    feh --bg-fill ~/.wallpapers/alena-aenami-horizon-1k_upscaled.jpg
    picom -b
    ~/.config/polybar/launch.sh
    nice -n 19 betterlockscreen -u "$HOME/.wallpapers/tokyo-night-space_upscaled.png" --display 1 &
) &

# Services
~/.config/tmux/utils/start_all_servers.sh &
dbus-launch dunst --config ~/.config/dunst/dunstrc &

# Apps
xdg-settings set default-web-browser librewolf.desktop
"$HOME/.scripts/utils/setup_keyboard.sh"
birdtray &
