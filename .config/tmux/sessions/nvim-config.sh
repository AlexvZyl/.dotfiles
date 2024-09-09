#!/bin/bash


FILE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$FILE_DIR/../utils/sessions.sh"


Tmux_create_session "nvim-config"\
    "$HOME/.config/nvim"
