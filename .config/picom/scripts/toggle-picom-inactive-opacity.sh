# Data.
NO_DIM="inactive-opacity = 1.00;"
DIM="inactive-opacity = 0.85;"
FILENAME="/home/alex/.config/picom/picom.conf"
STATE_FILE="/home/alex/.config/picom/read-mode-state"

# Clear the file contents.
> $STATE_FILE

# Check dim state.
if grep -Fxq "$DIM" $FILENAME

# Currently dim.
then
    sed -i "s/$DIM/$NO_DIM/g" $FILENAME
    echo ' On' >> $STATE_FILE
# Currently no dim.
else
    sed -i "s/$NO_DIM/$DIM/g" $FILENAME
    echo 'Off' >> $STATE_FILE
fi
