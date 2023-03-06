# Disable fish greeting.
set fish_greeting "" 

# Customize tide.
# set -g tide_right_prompt_items status cmd_duration jobs time
set -g tide_left_prompt_items os context pwd git newline character 
set -g tide_right_prompt_items jobs cmd_duration status time
set -g tide_git_icon ''
set -g tide_status_icon_failure ''
set -g tide_character_icon " "
set -g tide_pwd_icon "  "
set -g tide_pwd_icon_home "  "
set -g tide_time_format " %H:%M:%S"
set -g tide_time_bg_color D8DEE9

# Add alias for dotfile tracking with git.
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Configure pfetch.
set -gx PF_INFO "ascii title kernel os wm pkgs memory uptime"
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

# Unlock pacman.
alias unlock='sudo rm /var/lib/pacman/db.lck'

# Trash.
alias trash="trash --trash-dir ~/.trash"

# Julia.
alias julia="clear && julialauncher"

pfetch
