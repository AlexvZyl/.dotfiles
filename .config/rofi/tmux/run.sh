#!/usr/bin/env bash

# Define the directory to search for files
dir="$HOME/.config/tmux/sessions"
prefix="󱫋  "

# Get a list of files in the directory and store it in an array
files=("$dir"/*)

# Extract only the filenames from the full paths
# and store them in a separate array
filenames=()
for file in "${files[@]}"; do
  filename=$(basename "$file")
  filename="${filename%.sh}"
  filenames+=("$prefix${filename}")
done

# Use Rofi to display the list of filenames as a plain text menu
selected_file=$(
    printf '%s\n' "${filenames[@]}" | \
    rofi \
        -config "$HOME/.config/rofi/tmux/style.rasi" \
        -dmenu \
        -p "󱓞  Tmux"
)

# Check if the user selected a file
if [[ -n $selected_file ]]; then
    script="${selected_file#$prefix}"
    kitty --class tmux-$name --execute $HOME/.config/tmux/sessions/$script.sh
fi
