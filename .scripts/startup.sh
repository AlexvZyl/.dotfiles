#!/bin/bash 

# Setup the arandr monitor layout.
~/.screenlayout/default_triple_monitor.sh 

# Launch polybar.
~/.config/polybar/launch.sh

# Get rid of that screen tearing.
# Unsure if this will make startup slower?...
nvidia-force-comp-pipeline

# Start compositor.
picom -b --experimental-backend
