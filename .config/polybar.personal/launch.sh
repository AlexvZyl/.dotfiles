#!/usr/bin/env sh

# if type "xrandr" > /dev/null; then
    # for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        # MONITOR=$m polybar --reload mainbar-i3 -c ~/.config/polybar/config &
    # done
# else
    # polybar --reload mainbar-i3 -c ~/.config/polybar/config &
# fi

# second polybar at bottom
# if type "xrandr" > /dev/null; then
#   for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#     MONITOR=$m polybar --reload mainbar-i3-extra -c ~/.config/polybar/config &
#   done
# else
# polybar --reload mainbar-i3-extra -c ~/.config/polybar/config &
# fi
#;;

polybar --quiet --reload mainbar-i3 -c ~/.config/polybar.personal/config.ini &
