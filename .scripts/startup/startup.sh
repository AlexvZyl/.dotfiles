#!/bin/bash 

# Get rid of that screen tearing.
# Unsure if this will make startup slower?...
nvidia-force-comp-pipeline &

# Start compositor.
picom -b &
xborders -c ~/.config/picom/xborder.json &

# Setup the arandr monitor layout AFTER compositor and BEFORE wallpaper.
~/.screenlayout/default_triple_monitor.sh
# ~/.screenlayout/default_double_monitor.sh

# Set wallpaper AFTER compositor.
feh --bg-fill ~/.wallpapers/Cloud_2_Nord.png

# Launch polybar.
~/.config/polybar/launch.sh

# Update loadshedding schedule.
~/.config/cron/update_loadshedding.sh &
