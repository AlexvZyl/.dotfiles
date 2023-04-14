#!/bin/bash

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
export DISPLAY=:0.0 
notify-send --expire-time=30000 --urgency=critical " 󰚩  Sit die geyser af. "
