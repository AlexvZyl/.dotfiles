#!/bin/bash

KNOWN_THREATS=0
RESULT=$(sudo fail2ban-client status sshd | grep "Currently banned" | grep -Eo "[0-9]+")

if [[ RESULT -eq KNOWN_THREATS ]]; then
    echo "%{F#9ece6a}󰒃 "
else
    echo "%{F#9ece6a}󰒃 %{F-}$RESULT "
fi
