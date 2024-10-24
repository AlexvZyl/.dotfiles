source "$HOME/.private/env.sh" && true

# Environment.
export TERM="wezterm"
export TERMINAL=$TERM
export COLORTERM=$TERM
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export EDITOR="nvim"
export VISUAL=$EDITOR
export BAT_THEME="base16-256"
export PATH="$HOME/.local/bin/:$PATH"

# Dotfiles.
alias config='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lazygit-dotfiles='lazygit --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias lgd='lazygit-dotfiles'

# Utils.
alias ls='eza --grid --long --header --no-permissions --no-time --across'
alias pdf="nohup zathura"
alias cat="bat"
alias rm="trash --trash-dir ~/.trash"  # This one has saved me a lot of heartache...
alias clear-trash="yes | $(which rm) -r ~/.trash/files/"
alias tssh='TERM=xterm-256color ssh'
alias c="clear"
alias z="zathura"
alias picom-restart="pkill picom;\
    sleep 0.01;\
    picom -b"
alias git-stats="git log --stat --pretty=tformat: --numstat | awk '{add+=\$1; subs+=\$2} END {print \"Total additions:\", add, \"\nTotal deletions:\", subs}'"

alias view-root="sudo dua -i /home  i /"
alias view-trash="dua i \$HOME/.trash/"
alias view-home="dua i \$HOME/"

# Peripherals.
alias setup-keyboard="~/.scripts/utils/setup_keyboard.sh"
alias setup-monitors="feh --bg-fill \$HOME/.wallpapers/alena-aenami-horizon-1k_upscaled.jpg
    nice -n 19 betterlockscreen -u \"\$HOME/.wallpapers/tokyo-night-space_upscaled.png\" --display 1"

# Dev.
alias lg="lazygit"
alias lzd="lazydocker"
alias nh="nvim ."
alias gl="git log --oneline --decorate --graph"
alias tmux-workspace="~/.config/tmux/utils/create_workspace.sh"
alias tw="tmux-workspace"
alias tks="tmux kill-session"
alias tclear="tmux clear-history"

# Nix aliases.
alias nix-shell="$(which nix-shell) --command \"echo; fish\""
alias nix-build="sudo nixos-rebuild switch --flake \$HOME/.nixos#default --impure && notify-send 'NixOS' 'Build complete.' || notify-send --urgency=critical 'NixOS' 'Build failed.'"
alias nix-update="nix flake update \$HOME/.nixos && sudo nix-channel --update && notify-send 'NixOS' 'Channels updated.' || notify-send --urgency=critical 'NixOS' 'Update failed.'"
alias nix-clear="sudo nix-collect-garbage --delete-older-than"
alias nix-python-activate="LD_LIBRARY_PATH=\$(nix eval --raw nixpkgs#stdenv.cc.cc.lib)/lib \
    $(which nix-shell) \
    -p python3 python3Packages.virtualenv \
    --command 'virtualenv venv; source venv/bin/activate; clear; fish;'\
"
alias npa="nix-python-activate"
alias nix-update-build="nix-update && nix-build"
alias nub="nix-update-build"
