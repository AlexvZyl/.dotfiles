# Environment.
export TERMINAL="xterm-kitty"
export TERM="xterm-kitty"
export COLORTERM="xterm-kitty"
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export EDITOR="nvim"
export VISUAL="vscodium"
export JULIA_NUM_THREADS=8
export BAT_THEME="base16-256"

# PATH
export PATH="$HOME/.local/bin/:$PATH"

# Dotfiles.
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Aliasses.
alias lg='lazygit'
alias lazygit-dotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lgd='lazygit-dotfiles'
alias ls='exa --grid --long --header --no-permissions --no-time --across'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias julia="clear && julialauncher"
alias pdf="nohup zathura"
alias rst="reset && echo \"\" && pfetch"
alias cat="bat"
alias rm="trash --trash-dir ~/.trash"  # This one has saved me a lot of heartache...
alias clear-trash="/usr/bin/rm -rdf ~/.trash/files/*"
alias kitty-ssh='kitty +kitten ssh'
alias workspace-git="git --work-tree=$HOME --git-dir=$HOME/.workspace"
alias workspace-lazygit="lazygit --git-dir=$HOME/.workspace --work-tree=$HOME"
alias pexec="pyenv exec python3"

# AWS
alias sky-status="sky status --refresh"

# Utils
alias check-root="dua -i /home  i /"
alias c="clear"
alias nh="nvim ."
alias z="zathura"
alias tks="tmux kill-session"
alias gl="git log --oneline --graph"
alias picom-restart="pkill picom;\
    sleep 0.01;\
    picom -b"
