#!/bin/bash

source ~/.config/tmux/utils/workspace_env.sh
session="DawnCraft-Server"

if ! tmux has-session -t $session >/dev/null 2>&1; then
    path="$HOME/Repositories/minecraft-server"
    file="$path/.github/README.md"
    tmux new-session -d -s $session -c $path -n nvim "nvim $file"
    tmux new-window -c $path -n "git" "lazygit"
    tmux new-window -c $path -n "remote" "ssh $session"
    tmux split-window -h "ssh $session"
fi

tmux attach-session -t $session
