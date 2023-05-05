#!/bin/bash

# Clone.
sudo pacman -S git
mkdir ~/.dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME clone --bare https://github.com/AlexvZyl/.dotfiles ~/.dotfiles/
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout -f

# Needed for install.
~/.scripts/install/links.sh

# Install yay and packages.
~/.scripts/packages/bootstrap.sh

# Setup git.
gh auth login
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no

# Get modules.
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME submodule update --recursive --remote

# Run main install script.
~/.scripts/install/install.sh
