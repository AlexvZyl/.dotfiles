#!/bin/sh


# Get name.
if [ -n "$1" ]; then
    WORKSPACE_NAME=$1
else
    WORKSPACE_NAME=$(basename "$(pwd)")
fi


# Switch to existing session if it already exists.
if tmux has-session -t "$WORKSPACE_NAME" >/dev/null 2>&1; then
    tmux switch -t "$WORKSPACE_NAME"
    exit 0
fi


# Create new session.
tmux rename-session "$WORKSPACE_NAME"
CURRENT_WINDOW=$(tmux display-message -p '#I')
tmux rename-window "editor"
tmux new-window -c "./" -n "git" "lazygit"
tmux new-window -c "./" -n "shell" "fish"
tmux select-window -t "$CURRENT_WINDOW"
tmux swap-window -t +1
tmux next-window
tmux select-window -t 1
nvim .
