#!/bin/bash


Tmux_session_exists() {
    local session="$1"
    tmux has-session -t "$session" >/dev/null 2>&1
}


Tmux_attach_session() {
    local session="$1"
    tmux attach-session -t "$session"
}


Tmux_create_session() {
    local session="$1" path="$2" git_cmd="$3"

    if [[ -z "$git_cmd" ]]; then
        git_cmd="lazygit"
    fi

    if ! Tmux_session_exists "$session"; then
        tmux new-session -d -s "$session" -c "$path" -n "git" "$git_cmd"
        tmux new-window -c "$path" -n nvim "sleep 0.2 && nvim ." &
        tmux new-window -c "$path" -n "shell" fish
        wait
        tmux select-window -t 2
    fi

    Tmux_attach_session "$session"
}
