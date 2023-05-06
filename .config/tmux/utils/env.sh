#!/bin/bash

export TMUX="/tmp/tmux-workspace"
if ! [ -z "$(tmux list-sessions 2>&1 >/dev/null)" ]; then
    tmux start-server
fi
