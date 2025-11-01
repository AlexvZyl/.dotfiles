#!/usr/bin/env -S bash -e


Exit_if_not_nvim() {
    # TODO: This is not reliable.
    if [[ ! $(tmux display-message -p '#{pane_current_command}') == "nvim" ]]; then
        exit 0
    fi
}


Main() {
    Exit_if_not_nvim
    tmux split-window -h -b -p 33 -c "#{pane_current_path}" "opencode ."
}


Main "$@"
