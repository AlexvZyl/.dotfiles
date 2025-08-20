#!/bin/bash -e


Get_current_buffer_file() {
    local tmp_file, tmp_dir
    tmp_dir="/tmp/${USER}/$(uuidgen)"
    tmp_file="${tmp_dir}/nvim_current_buffer"
    mkdir -p "$tmp_dir"

    # HACK: Use neovim to copy the filepath to the clipboard.
    tmux send-keys ":let @+ = expand('%:p') | !echo %:p > ${tmp_file} && exit" C-m
    sleep 0.2

    cat "$tmp_file"
    rm -rd "$tmp_dir"
}


Get_pwd() (
    local path="${1#oil://}"

    local dir="$path"
    if [[ -f "$path" ]]; then
        dir="$(dirname "$path")"
    fi
    cd "$dir"
    
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        echo "$dir"
    fi
)


Exit_if_not_nvim() {
    # TODO: This is not reliable.
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
    
    tmux split-window -h -p 40 -c "$pwd" "claude"
}


Main "$@"
