#!/bin/bash -e


Get_current_buffer_file() {
    local tmp_file, tmp_dir
    tmp_dir="/tmp/${USER}/$(uuidgen)"
    tmp_file="${tmp_dir}/nvim_current_buffer"

    # HACK: Use neovim to copy the filepath to the clipboard.
    tmux send-keys -t ! ':let @+ = expand("%:p")' Enter

    mkdir -p "$tmp_dir"
    tmux send-keys -t 0 ":!echo %:p > ${tmp_file} && exit" C-m
    # Give neovim some time.
    sleep 0.1

    cat "$tmp_file"
    rm -rd "$tmp_dir"
}


Get_pwd() (
    local file="$1"
    cd "$(dirname "$file")"
    
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        dirname "$file"
    fi
)


Exit_if_not_nvim() {
    if [[ ! $(tmux display-message -p '#{pane_current_command}') == "nvim" ]]; then
        exit 0
    fi
}


Main() {
    Exit_if_not_nvim

    local current_buffer
    current_buffer=$(Get_current_buffer_file)

    xclip -selection clipboard <<< "$current_buffer"
    pwd=$(Get_pwd "$current_buffer")
    
    tmux split-window -h -c "$pwd" "claude"
}


Main "$@"
