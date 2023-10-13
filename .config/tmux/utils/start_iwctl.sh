#!/bin/bash
tmux new-session -n "wifi" "iwctl && station wlan0 scan && station wlan0 get-networks"
