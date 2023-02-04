#!/bin/bash 

# Launch polybar.
~/.config/polybar/launch.sh

# Get rid of that screen tearing.
# Unsure if this will make startup slower?...
nvidia-force-comp-pipeline

# Start compositor.
picom -b 

# Setup the arandr monitor layout AFTER compositor and BEFORE wallpaper.
~/.screenlayout/default_triple_monitor.sh 

# Set wallpaper AFTER compositor.
# feh --bg-fill ~/.wallpapers/IGN_Astronaut_Nord.png
feh --bg-fill ~/.wallpapers/Cloud_2_Nord.png
