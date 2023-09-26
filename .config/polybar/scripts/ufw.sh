#!/bin/bash

if systemctl is-active --quiet ufw; then
    echo "%{F#9ece6a}󱨑 "
else
    echo "%{F#db4b4b}󱨑 "
fi


