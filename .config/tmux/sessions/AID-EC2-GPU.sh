#!/bin/bash

session="AID-EC2-GPU"

if ! tmux has-session -t "$session" >/dev/null 2>&1; then
    path="$HOME/AdvanceGuidance/Remotes/tb-model-dev/"
    file="$path/README.md"
    mkdir -p path
    tmux new-session -d -s "$session" -c "$path" -n nvim "source ${path}/venv/bin/activate && nvim $file"
    tmux new-window -c "$path" -n "shell" "source ${path}/venv/bin/activate && fish"
    tmux new-window -n "remote" "ssh AdvanceGuidance_GPU"
    tmux select-window -t 1
fi

tmux attach-session -t "$session"
