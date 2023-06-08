#!/bin/bash

source ~/.config/tmux/utils/workspace_env.sh
session="DawnCraft-Server"

if ! tmux has-session -t $session >/dev/null 2>&1; then
    path="$HOME/Repositories/minecraft-server"
    file="$path/.github/README.md"
    tmux new-session -d -s $session -c $path -n nvim "nvim $file"
    tmux new-window -c $path -n "git" "lazygit"
    tmux new-window -n "remote-monitor" "ssh $session"
    tmux send-keys "btop" Enter
    tmux new-window -n "remote-logs" "ssh $session"
    tmux send-keys "cd minecraft-server" Enter
    tmux send-keys "nvim-logs" Enter
    tmux new-window -n "remote-shell" "ssh $session"
    tmux send-keys "cd minecraft-server" Enter
    tmux send-keys "clear" Enter
fi

tmux attach-session -t $session
