#!/bin/bash -e


Main() {
    rofi                                \
        -show drun                      \
        -config "$HOME/.config/rofi/config.rasi"
}


Main "$@"
