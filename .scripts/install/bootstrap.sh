#!/bin/bash

if [ -z ${SUDO_USER} ]
then
    export USER_HOME="$HOME"
else
    export USER_HOME="/home/${SUDO_USER}"
fi

# Clone.
sudo pacman -S git
mkdir ~/.dotfiles
git --git-dir=$USER_HOME/.dotfiles/ --work-tree=$USER_HOME clone --bare https://github.com/AlexvZyl/.dotfiles $USER_HOME/.dotfiles/
git --git-dir=$USER_HOME/.dotfiles/ --work-tree=$USER_HOME checkout -f

# Needed for install.
$USER_HOME/.scripts/install/links.sh

# Install yay and packages.
$USER_HOME/.scripts/packages/bootstrap.sh

# Setup git.
gh auth login
git --git-dir=$USER_HOME/.dotfiles/ --work-tree=$USER_HOME config --local status.showUntrackedFiles no

# Get modules.
git --git-dir=$USER_HOME/.dotfiles/ --work-tree=$USER_HOME submodule update --recursive --remote

# Run main install script.
$USER_HOME/.scripts/install/install.sh
