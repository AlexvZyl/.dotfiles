# Environment.
export TERMINAL="xterm-kitty"
export TERM="xterm-kitty"
export COLORTERM="xterm-kitty"
export MANPAGER='nvim +Man!'
#export MANPAGER='less'
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
#alias ls='clear && exa --grid --long --header --no-permissions --no-time --across'
alias ls='exa --grid --long --header --no-permissions --no-time --across'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias julia="clear && julialauncher"
alias pdf="nohup zathura"
alias rst="reset && echo \"\" && pfetch"
# alias cat="cat && bat"
alias rm="trash --trash-dir ~/.trash"  # This one has saved me a lot of heartache...
alias clear-trash="/usr/bin/rm -rdf ~/.trash/files/*"
alias kitty-ssh='kitty +kitten ssh'
alias workspace-git="git --work-tree=$HOME --git-dir=$HOME/.workspace"
alias workspace-lazygit="lazygit --git-dir=$HOME/.workspace --work-tree=$HOME"
alias pexec="pyenv exec python3"

# Gotta go fast
alias c="clear"
alias nh="nvim ."
alias z="zathura"
alias tks="tmux kill-session"
alias gl="git log --oneline --graph"
alias picom-restart="pkill picom;\
    picom -b"

# Remoting
alias ssh='kitty +kitten ssh'
alias rsync-aid="rsync -avz --progress --include src/data/ --exclude build/ --exclude .vscode --exclude .pytest_cache --exclude .git/ \
    --exclude venv/ --exclude \"*.egg-info\" --exclude \"*.pkl\" --exclude aws/ --exclude data/ --exclude output/ --exclude beats-models \
    --exclude models --exclude \"*.csv\" --exclude \"*.png\""
alias rsync-aid-to-local="rsync-aid AdvanceGuidance_GPU:/home/ubuntu/mnt/tb-mdel-dev/ ~/AdvanceGuidance/Remotes/tb-model-dev/"
alias rsync-aid-to-remote="rsync-aid ~/AdvanceGuidance/Remotes/tb-model-dev/ AdvanceGuidance_GPU:/home/ubuntu/mnt/tb-mdel-dev/"

# AWS
alias sky-status="sky status --refresh"
