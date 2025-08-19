#!/bin/bash -e


Main() {
    rofi                                \
        -show drun                      \
        -display-drun "󱓞  Apps"         \
        -config "$HOME/.config/rofi/config.rasi"
}


Main "$@"
