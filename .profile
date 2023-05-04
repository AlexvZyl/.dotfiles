# Terminal.
export TERMINAL="xterm-256color"
export TERM="xterm-256color"
export COLORTERM="xterm-256color"

# Manpager.
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# Aliasses.
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazygit-dotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lg='lazygit'
alias lgd='lazygit-dotfiles'
alias ls='clear -x && exa --grid --long --header --no-permissions --no-time --across'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias rm="trash --trash-dir ~/.trash"
alias julia="clear && julialauncher"
alias pdf="nohup zathura"
alias rst="reset && pfetch"
