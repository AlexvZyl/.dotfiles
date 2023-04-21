#!/bin/bash 

# Get rid of that screen tearing.
# Unsure if this will make startup slower?...
nvidia-force-comp-pipeline

# Start compositor.
picom -b

# Setup the arandr monitor layout AFTER compositor and BEFORE wallpaper.
~/.screenlayout/default_triple_monitor.sh

# Set wallpaper AFTER compositor.
feh --bg-fill ~/.wallpapers/Cloud_2_Nord.png

# Launch polybar.
~/.config/polybar/launch.sh

# Update loadshedding schedule.
python ~/.config/polybar/scripts/update_loadshedding.py

# Environment variables.
export $EDITOR="nvim"
