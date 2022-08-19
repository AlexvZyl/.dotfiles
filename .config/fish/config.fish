# Disable fish greeting.
set fish_greeting "" 

# Customize tide.
# set -g tide_right_prompt_items status cmd_duration jobs time
set -g tide_left_prompt_items os context pwd git newline character 
set -g tide_git_icon 
set -g tide_status_icon_failure 
# set -g tide_character_icon " "
set -g tide_character_icon " "
# set -g tide_character_icon ﰳ
# set -g tide_character_icon ﯀
# set -g tide_character_icon  " ﬌ " 
# set -g tide_character_icon  " "
# set -g tide_character_icon  "  "
# set -g tide_character_icon  "  "
# set -g tide_character_icon  "  "

# Add alias for dotfile tracking with git.
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
