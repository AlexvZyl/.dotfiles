#!/bin/bash

source ~/.config/tmux/utils/workspace_env.sh
session="minecraft-server"

if ! tmux has-session -t $session >/dev/null 2>&1; then
    path="$HOME/Repositories/minecraft-server"
    file="$path/README.md"
    tmux new-session -d -s $session -c $path -n nvim "nvim $file"
    tmux new-window -c $path -n "git" "lazygit"
    tmux new-window -c "$path/modpack/packwiz" -n "packwiz"
    tmux new-window -c $path -n "server"
    tmux select-window -t 1
fi

tmux attach-session -t $session
