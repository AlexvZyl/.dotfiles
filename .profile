# Environment.
export TERMINAL="xterm-kitty"
export TERM="xterm-kitty"
export COLORTERM="xterm-kitty"
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export EDITOR="nvim"
export VISUAL="vscodium"
export JULIA_NUM_THREADS=8

# PATH
export PATH="$HOME/.local/bin/:$PATH"

# Aliasses.
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lg='lazygit'
alias lazygit-dotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lgd='lazygit-dotfiles'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias julia="clear && julialauncher"
alias pdf="nohup zathura"
alias rst="reset && echo \"\" && pfetch"
alias kitty-ssh='kitty +kitten ssh'
