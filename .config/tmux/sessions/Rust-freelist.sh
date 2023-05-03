#!/bin/bash

session="Rust-freelist"
path="$HOME/GitHub/freelist/src"
file="$path/lib.rs"

tmux start-server

if ! tmux has-session -t $session >/dev/null 2>&1; then
    tmux new-session -d -s $session -c $path -n nvim "nvim $file"
    tmux source-file ~/.config/tmux/neovim.conf
    
    tmux new-window -c $path -n "cargo"
    tmux new-window -c $path -n "lazygit" "lazygit"
    tmux select-window -t 1
fi

tmux attach-session -t $session
