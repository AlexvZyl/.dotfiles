# Disable fish greeting.
set fish_greeting "" 

# Customize tide.
# set -g tide_right_prompt_items status cmd_duration jobs time
set -g tide_left_prompt_items os context pwd git newline character 
set -g tide_git_icon 
set -g tide_status_icon_failure 
set -g tide_character_icon " "
# set -g tide_character_icon " "
# set -g tide_character_icon ﰳ
# set -g tide_character_icon ﯀
# set -g tide_character_icon  " ﬌ " 
# set -g tide_character_icon  " "
# set -g tide_character_icon  "  "
# set -g tide_character_icon  "  "
# set -g tide_character_icon  "  "

# Add alias for dotfile tracking with git.
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Configure pfetch.
set -gx PF_INFO "ascii title kernel os wm uptime pkgs memory palette"
set -gx PF_COL1 "4"
set -gx PF_COL2 "9"
set -gx PF_COL3 "1"

# Use lazygit with the config.
alias lazygit-dotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Use neovim as manpage pager.
set -x MANPAGER 'nvim +Man!'
set -x MANWIDTH 999

# Replace ls with exa.
alias ls='exa --grid --long --header --no-permissions --no-time --across'
