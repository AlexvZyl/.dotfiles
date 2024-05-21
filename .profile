# Environment.
export TERM="wezterm"
export TERMINAL=$TERM
export COLORTERM=$TERM
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export EDITOR="nvim"
export VISUAL=$EDITOR
export JULIA_NUM_THREADS=8
export BAT_THEME="base16-256"
export PATH="$HOME/.local/bin/:$PATH"

# Dotfiles.
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Utils.
alias lg='lazygit'
alias lazygit-dotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lgd='lazygit-dotfiles'
alias pdf="nohup zathura"
alias cat="bat"
alias rm="trash --trash-dir ~/.trash"  # This one has saved me a lot of heartache...
alias clear-trash="$(which rm) -r ~/.trash/files/"
alias tssh='TERM=xterm-256color ssh'
alias workspace-git="git --work-tree=\$HOME --git-dir=\$HOME/.workspace"
alias workspace-lazygit="lazygit --git-dir=\$HOME/.workspace --work-tree=\$HOME"
alias pexec="pyenv exec python3"
alias check-root="sudo dua -i /home  i /"
alias c="clear"
alias z="zathura"
alias tks="tmux kill-session"
alias picom-restart="pkill picom;\
    sleep 0.01;\
    picom -b"

# AWS
alias sky-status="sky status --refresh"

# Peripherals.
alias setup-keyboard="~/.scripts/utils/setup_keyboard.sh"
alias setup-monitors="feh --bg-fill \$HOME/.wallpapers/alena-aenami-horizon-1k_upscaled.jpg
    nice -n 19 betterlockscreen -u \"\$HOME/.wallpapers/tokyo-night-space_upscaled.png\" --display 1"

# Dev.
alias nh="nvim ."
alias gl="git log --oneline --decorate --graph"
alias tmux-workspace="~/.config/tmux/utils/create_workspace.sh"
alias tw="tmux-workspace"

# Nix aliases.
alias nix-build="sudo nixos-rebuild switch --flake \$HOME/.nixos#default --impure"
alias nix-clear="sudo nix-collect-garbage --delete-older-than 7d"
alias nix-python-activate="LD_LIBRARY_PATH=\$(nix eval --raw nixpkgs#stdenv.cc.cc.lib)/lib \
    nix-shell \
    -p python3 python3Packages.virtualenv \
    --command 'virtualenv venv; source venv/bin/activate; return'\
"
alias npa="nix-python-activate"
