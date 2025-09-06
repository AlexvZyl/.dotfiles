#!/usr/bin/env bash
#shellcheck disable=1090,1091


Main() {
    source "$HOME/.profile"
    
    local env_file="$HOME/.private/env.sh"
    if [[ -f $env_file ]]; then
        source "$env_file"
    fi
    
    # TODO: Why does this complain?
    zoxide init bash | source 2>/dev/null
    [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
}


Main "$@"
