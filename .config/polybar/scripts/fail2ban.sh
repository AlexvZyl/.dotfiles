#!/bin/bash


KNOWN_THREATS=0


Main() {
    local result
    result=$(sudo fail2ban-client status sshd 2>/dev/null | grep "Currently banned" | awk '{print $4}')

    if [ -z "$result" ]; then
        echo "󰦞 "

    elif [[ "$result" -eq "$KNOWN_THREATS" ]]; then
        echo "󰒃 "

    else
        echo "󰒃 $((result - KNOWN_THREATS))"
    fi
}


Main "$@"
