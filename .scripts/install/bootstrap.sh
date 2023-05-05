#!/bin/bash

# Clone.
pacman -S git
alias config="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
mkdir ~/.dotfiles
config clone --bare https://github.com/AlexvZyl/.dotfiles ~/.dotfiles/
config checkout -f

# Install yay and packages.
~/.scripts/packages/setup.sh

# Setup git.
gh auth login
config config --local status.showUntrackedFiles no

# Get modules.
config submodule update --recursive --remote

# Run main install script.
~/.scripts/install/install.sh
