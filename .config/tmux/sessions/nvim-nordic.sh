#!/bin/bash

session="nvim-nordic"

if ! tmux has-session -t "$session" >/dev/null 2>&1; then
    path="$HOME/.local/share/nvim/lazy/nordic.nvim/lua/nordic"
    file="$path/init.lua"
    tmux new-session -d -s "$session" -c "$path" -n nvim "nvim $file"
    tmux new-window -c "$path" -n "shell" fish
    tmux new-window -c "$path" -n "git" "lazygit"
    tmux select-window -t 1
fi

tmux attach-session -t "$session"
