#!/bin/bash

source "$HOME/.profile"
if [ -e ~/.private/env.sh ]; then
    source ~/.private/env.sh
fi

. "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
