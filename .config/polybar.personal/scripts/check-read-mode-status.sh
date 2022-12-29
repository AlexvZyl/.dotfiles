# Check dim state.
if grep -Fxq "inactive-opacity = 0.85;" /home/alex/.config/picom/picom.conf

# Currently dim.
then
    echo " "

# Currently no dim.
else
    echo " "
fi
