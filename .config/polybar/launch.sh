#!/bin/sh

# # Create env variable for polybar CPU temp.
# for i in /sys/class/hwmon/hwmon*/temp*_input; do
#     if [ "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*}))" = "coretemp: temp1_input" ]; then
#         export HWMON_PATH="$i"
#     fi
# done

polybar --reload --quiet top -c ~/.config/polybar/config.ini &
