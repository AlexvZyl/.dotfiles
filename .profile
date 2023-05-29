# Environment.
export TERMINAL="xterm-kitty"
export TERM="xterm-kitty"
export COLORTERM="xterm-kitty"
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export EDITOR="nvim"
export VISUAL="vscodium"
export JULIA_NUM_THREADS=8

# Aliasses.
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lg='lazygit'
alias lazygit-dotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lgd='lazygit-dotfiles'
alias ls='exa --grid --long --header --no-permissions --no-time --across'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias julia="clear && julialauncher"
alias pdf="nohup zathura"
alias rst="reset && pfetch"
alias cat="bat"
alias rm="trash --trash-dir ~/.trash"  # This one has saved me a lot of heartache...
alias clear-trash="/usr/bin/rm -rdf .trash/files/*"
