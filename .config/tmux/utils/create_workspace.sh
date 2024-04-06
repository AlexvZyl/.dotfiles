#!/bin/sh

WORKSPACE_NAME=""
if [ -n "$1" ]; then
    WORKSPACE_NAME=$1
else
    WORKSPACE_NAME=$(basename "$(pwd)")
fi
tmux rename-session "$WORKSPACE_NAME"

CURRENT_WINDOW=$(tmux display-message -p '#I')
echo "$CURRENT_WINDOW"

tmux rename-window "editor"
tmux new-window -c "./" -n "git" "lazygit"
tmux new-window -c "./" -n "shell" "fish"

tmux select-window -t "$CURRENT_WINDOW"
nvim .
