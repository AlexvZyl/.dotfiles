#!/bin/sh

KNOWN_THREATS=0
RESULT=$(fail2ban-client status sshd &>/dev/null | grep "Currently banned" | grep -Eo "[0-9]+")

if [ -z "$RESULT" ]; then
    echo "%{F#db4b4b}󰦞 "
elif [[ RESULT -eq KNOWN_THREATS ]]; then
    echo "%{F#9ece6a}󰒃 "
else
    echo "%{F#9ece6a}󰒃 %{F-}$RESULT "
fi
