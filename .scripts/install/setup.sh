#!/bin/bash

# Clone.
sudo pacman -S git
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
mkdir ~/.dotfiles
config clone --bare https://github.com/AlexvZyl/.dotfiles ~/.dotfiles/
config checkout -f

# Run main install script.
~/.scripts/install/install.sh
