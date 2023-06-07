#!/bin/bash

source ~/.config/tmux/utils/workspace_env.sh
session="minecraft-server"

if ! tmux has-session -t $session >/dev/null 2>&1; then
    path="$HOME/Repositories/minecraft-server"
    file="$path/.github/README.md"
    tmux new-session -d -s $session -c $path -n nvim "nvim $file"
    tmux new-window -c $path -n "git" "lazygit"
    tmux new-window -c $path -n "remote" "ssh mc-server@160.119.253.57"
    tmux split-window -h "ssh mc-server@160.119.253.57"
fi

tmux attach-session -t $session
