#!/bin/bash -e


# TODO: Try to move all of this to nix.

# Core components (order is important!)
(
    ~/.scripts/screenlayout/box_double_monitor.sh
    # feh --bg-fill ~/.wallpapers/stay_by_aenami_dbnb1k3.png
    feh --bg-fill ~/.wallpapers/Gruvbox_Forest_Mountain.png
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
