#!/bin/bash 

# Setup the arandr monitor layout.
~/.screenlayout/default_triple_monitor.sh 
# ~/.screenlayout/default_double_monitor.sh

# Get rid of that screen tearing.
# Unsure if this will make startup slower?...
nvidia-force-comp-pipeline

# Start compositor.
picom -b 

# Create env variable for polybar CPU temp.
for i in /sys/class/hwmon/hwmon*/temp*_input; do 
    if [ "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*}))" = "coretemp: temp1_input" ]; then
        export HWMON_PATH="$i"
    fi
done
# Launch polybar.
~/.config/polybar.personal/launch.sh
