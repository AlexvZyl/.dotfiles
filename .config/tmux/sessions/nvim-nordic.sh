#!/bin/bash

source ~/.config/tmux/utils/env.sh
session="nvim-nordic"

if ! tmux has-session -t $session >/dev/null 2>&1; then
    path="$HOME/.local/share/nvim/site/pack/packer/start/nordic.nvim/lua/nordic/init.lua"
    tmux new-session -d -s $session -c $path -n nvim "nvim $path"
    tmux new-window -c $path -n "git" "lazygit"
    tmux new-window -c $path -n "shell"
    tmux select-window -t 1
fi

tmux attach-session -t $session
