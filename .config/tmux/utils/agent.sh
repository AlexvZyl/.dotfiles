#!/bin/bash -e


# TODO: Try to do this without using a tmp file.
Get_current_buffer_file() {
    local tmp_file, tmp_dir
    tmp_dir="/tmp/${USER}/$(uuidgen)"
    tmp_file="${tmp_dir}/nvim_current_buffer"
    mkdir -p "$tmp_dir"

    local id
    id=$(uuidgen)

    # HACK: Use neovim to copy the filepath to the clipboard.
    tmux send-keys ":!echo %:p > ${tmp_file}; tmux wait-for -S $id" C-m
    tmux wait-for "$id"
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
    pwd=$(Get_pwd "$current_buffer")
    
    tmux split-window -h -b -p 33 -c "$pwd" "claude"
    # tmux split-window -h -p 40 -c "$pwd" "codex"
}


Main "$@"
