#!/usr/bin/env bash
source ~/.config/tmux/utils/env.sh

# Define the directory to search for files
dir="$HOME/.config/tmux/sessions"
prefix="󱫋  "
active=" (active)"

# Get list of active sessions.
active_sessions=()
while IFS= read -r session; do
  active_sessions+=("$prefix${session}${active}")
done < <(~/.config/tmux/utils/workspace_sessions.sh)

# Get a list of files in the directory and store it in an array
files=("$dir"/*)

# Extract only the filenames from the full paths
# and store them in a separate array
filenames=()
for file in "${files[@]}"; do
  filename=$(basename "$file")
  session_name="${filename%.sh}"
  if tmux has-session -t $session_name 2>/dev/null; then
    state_name="$session_name$active"
  else
    state_name=$session_name
  fi
  filenames+=("$prefix${state_name}")
done

all_sessions=("${active_sessions[@]}")
all_sessions+=("${filenames[@]}")

# Use Rofi to display the list of filenames as a plain text menu
selected_file=$(
    printf '%s\n' "${all_sessions[@]}" | sort -u | \
    rofi \
        -config "$HOME/.config/rofi/tmux/style.rasi" \
        -dmenu \
        -p "󱓞  Tmux" \
        -no-custom
)

# Check if the user selected a file
if [[ -n $selected_file ]]; then
    script="${selected_file#$prefix}"
    session_name="${script%$active}"
    if tmux has-session -t $session_name; then
        kitty --class tmux-$session_name --execute tmux attach -t $session_name
    else
        kitty --class tmux-$session_name --execute $HOME/.config/tmux/sessions/$session_name.sh
    fi
fi
