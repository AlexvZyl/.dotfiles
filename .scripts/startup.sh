#!/bin/bash 

# Setup the arandr monitor layout.
~/.screenlayout/default_triple_monitor.sh 
# ~/.screenlayout/default_double_monitor.sh

# Get rid of that screen tearing.
# Unsure if this will make startup slower?...
nvidia-force-comp-pipeline

# Start compositor.
picom -b --experimental-backend

# Launch polybar.
~/.config/polybar.personal/launch.sh
