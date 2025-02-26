#!/bin/bash -e


Configure_network() {
    local NIC="enp5s0"
    local WIFI="wlp0s20f0u10"

    nmcli device connect "$NIC"
    nmcli device connect "$WIFI"

    local local_conn
    local_conn=$(nmcli -t -f NAME,DEVICE con show | grep "$NIC" | cut -d':' -f1)
    echo "$local_conn"

    local wifi_conn
    wifi_conn=$(nmcli -t -f NAME,DEVICE con show | grep "$WIFI" | cut -d':' -f1)
    echo "$wifi_conn"

    nmcli con mod "$local_conn" ipv4.addresses 192.168.50.1/24
    nmcli con mod "$local_conn" ipv4.method manual
    nmcli con mod "$local_conn" ifname enp5s0
    nmcli con up "$local_conn"

    nmcli con mod "$wifi_conn" ipv4.method auto
    nmcli con mod "$wifi_conn" ifname wlp0s20f0u10
}


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
