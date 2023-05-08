#!/bin/bash

if systemctl is-active --quiet ufw; then
    echo "%{F#A3BE8C}󱨑 "
else
    echo "%{F#BF616A}󱨑 "
fi


