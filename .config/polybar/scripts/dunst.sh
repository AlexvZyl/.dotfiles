#!/bin/bash -e


Main() {
    if [[ $(dunstctl is-paused) = true ]]; then 
        echo "paused"
        dunstctl set-paused toggle
        polybar-msg action dunst hook 0;
    else 
        echo "not"
        dunstctl set-paused toggle
        polybar-msg action dunst hook 1
    fi
}


Main "$@"
