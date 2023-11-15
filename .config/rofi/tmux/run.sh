#!/usr/bin/env bash

# Setup.
dir="$HOME/.config/tmux/sessions"
prefix="󱫋  "
active=" (active)"

# Active sessions.
readarray -t active_sessions < <(~/.config/tmux/utils/workspace_sessions.sh)
for ((i=0; i<${#active_sessions[@]}; i++)); do
  active_sessions[i]="$prefix${active_sessions[i]}$active"
done

# Get configs.
files=("$dir"/*.sh)
for (( i=0; i<${#files[@]}; i++ )); do
  file="${files[i]}"
  file="${file##*/}"
  session_name="${file%.sh}"
  if tmux has-session -t "$session_name" >/dev/null 2>&1; then
    state_name="$session_name$active"
  else
    state_name="$session_name"
  fi
  files[i]="${prefix}${state_name}"
done

# Combine sessions.
all_sessions=("${active_sessions[@]}")
all_sessions+=("${files[@]}")

# Display with rofi.
selected_file=$(printf '%s\n' "${all_sessions[@]}" | \
    rofi \
        -config "$HOME/.config/rofi/tmux/style.rasi" \
        -dmenu \
        -p "󱓞  Tmux" \
        -no-custom)

# Start selected session.
if [[ -n $selected_file ]]; then
    script="${selected_file#$prefix}"
    session_name="${script%$active}"
    if tmux has-session -t "$session_name" >/dev/null 2>&1; then
        kitty --class "tmux-$session_name" --execute tmux attach -t "$session_name"
    else
        kitty --class "tmux-$session_name" --execute "$HOME/.config/tmux/sessions/$session_name.sh"
    fi
fi

