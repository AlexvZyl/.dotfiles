#!/bin/bash

session="nixos-config"

if ! tmux has-session -t "$session" >/dev/null 2>&1; then
    path="$HOME/.nixos"
    file="$path/flake.nix"
    tmux new-session -d -s "$session" -c "$path" -n nvim "nvim $file"
    tmux new-window -c "$path" -n "git" "lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
    tmux new-window -c "$path" -n "shell" fish
    tmux select-window -t 1
fi

tmux attach-session -t "$session"
