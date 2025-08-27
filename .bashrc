#!/bin/bash

source "$HOME/.profile"
if [ -e ~/.private/env.sh ]; then
    source ~/.private/env.sh
fi

zoxide init bash | source
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
