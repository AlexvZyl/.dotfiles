#!/bin/bash

session="Masters-Thesis"
path="$HOME/GitHub/Masters-Thesis"
file="$path/USthesis_Masters.tex"

tmux start-server

if ! tmux has-session -t $session >/dev/null 2>&1; then
    tmux new-session -d -s $session -c $path -n nvim "nvim $file"
    tmux source-file ~/.config/tmux/neovim.conf
    
    tmux new-window -c $path -n "shell"
    tmux new-window -c $path -n "git" "lazygit"
    tmux select-window -t 1
fi

tmux attach-session -t $session
