#!/usr/bin/env -S bash -e


FILE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
source "$FILE_DIR/../utils/sessions.sh"


Tmux_create_session "nautical-rs" \
    "$HOME/NauticalTrading/Repos/grafana-algos-monitor/dependencies/nautical-rs"
