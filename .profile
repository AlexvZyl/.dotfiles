#shellcheck disable=2139,2148,1091,2142

source "$HOME/.private/env.sh" && true

# TSN.
export KEEP_SQUID_RUNNING="true"

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
alias restart-polybar="pkill polybar; ~/.config/polybar/launch.sh"

alias view-root-only="sudo dua -i /home  i /"
alias view-root="sudo dua i /"
alias view-trash="dua i \$HOME/.trash/"
alias view-home="dua i \$HOME/"

# Peripherals.
alias setup-keyboard="~/.scripts/utils/setup_keyboard.sh"
alias setup-wallpapers="feh --bg-fill \$HOME/.wallpapers/alena-aenami-quiet-1px.jpg & betterlockscreen -u \"\$HOME/.wallpapers/alena-aenami-quiet-1px.jpg\" --display 1"

# Dev.
alias lg="lazygit"
alias lzd="lazydocker"
alias nh="nvim ."
alias tmux-workspace="~/.config/tmux/utils/create_workspace.sh"
alias tw="tmux-workspace"
alias tks="tmux kill-session"
alias tclear="clear && tmux clear-history"
alias nvim-lsp-logs="nvim ~/.local/state/nvim/lsp.log" # TODO: Add to neovim itself?

# Git.
alias git-su="git submodule update --init --recursive --remote"
alias git-stats="git log --stat --pretty=tformat: --numstat | awk '!/\.lock\$/ {add+=\$1; subs+=\$2} END {print \"Total additions:\", add, \"\nTotal deletions:\", subs}'"
alias git-l="git log --oneline --decorate --graph"
alias git-sm-reset="git submodule deinit -f . && git submodule init && git submodule update --recursive"

# Nix aliases.
alias nix-shell="$(which nix-shell) --command \"echo; fish\""
alias nix-build="sudo nixos-rebuild switch --flake \$HOME/.nixos#default --impure && notify-send 'NixOS' 'Build complete.' || notify-send --urgency=critical 'NixOS' 'Build failed.'"
alias nix-update="sudo nix flake update --flake \$HOME/.nixos && sudo nix-channel --update nixos && notify-send 'NixOS' 'Channels updated.' || notify-send --urgency=critical 'NixOS' 'Update failed.'"
alias nix-clear="sudo nix-collect-garbage --delete-older-than"
alias nix-upgrade="sudo nixos-rebuild switch --upgrade --flake \$HOME/.nixos#default --impure && notify-send 'NixOS' 'Build complete.' || notify-send --urgency=critical 'NixOS' 'Build failed.'"
alias nix-list-builds="sudo nix-env -p /nix/var/nix/profiles/system --list-generations"

# TODO: Sort this out.
# alias nix-python-activate="LD_LIBRARY_PATH=\$(nix eval --raw nixpkgs#stdenv.cc.cc.lib)/lib \
#     $(which nix-shell) \
#     -p python3 python3Packages.virtualenv \
#     --command '
#         virtualenv venv;
#         source venv/bin/activate;
#         pip install --upgrade pip;
#         clear;
#         fish;
#         '\
# "
alias npa="nix-python-activate"
alias nix-update-build="nix-update && nix-upgrade"
alias nub="nix-update-build"

# Systemd stuff.
alias syspend="systemctl suspend"

# Misc.
alias monitor-interrupts="watch -n0.1 --no-title cat /proc/interrupts"
alias kalker="clear && $(which kalker)"
alias mount-trace="mount -t tracefs nodev /sys/kernel/tracing/ && ln -s /sys/kernel/tracing ./tracing"
alias setup-lockscreen="betterlockscreen -u \$HOME/.wallpapers/alena-aenami-quiet-1px.jpg --display 1"
alias lock-syspend="betterlockscreen -l & systemctl suspend"
alias watch-interrupts="watch -d -c -n0.1 \"cat /proc/interrupts\""
alias check-internet="bash -c \"while true; do ping google.com; sleep 1; done\""

# Security.
alias nmap-full="nmap -p- -v3 -A -T0 -f -Pn"

# AwesomeWM.
alias awesome-restart="'awesome.restart()' | awesome-client"

# Vpn_status() {
#     local vpn="$1"
# }
