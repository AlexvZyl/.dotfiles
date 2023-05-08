#!/bin/bash

RESULT=$(sudo fail2ban-client status sshd | grep "Currently banned" | grep -Eo "[0-9]+")

if [[ RESULT -eq 0 ]]; then
    echo "%{F#A3BE8C}󰒃 "
else
    echo "%{F#BF616A}󰒃 %{F-}$RESULT "
fi
