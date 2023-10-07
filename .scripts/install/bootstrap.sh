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
source $USER_HOME/.profile

# Needed for install.
$USER_HOME/.scripts/install/links.sh

# Install yay and packages.
$USER_HOME/.scripts/packages/bootstrap.sh

# Setup git.
gh auth login
config config --local status.showUntrackedFiles no

# Get modules.
config submodule update --init --force --remote .password-store/
config submodule update --init --force --remote .private/
config submodule update --init --force --remote .modules/user.js/
config submodule update --init --force --remote .config/nvim/

# Run main install script.
$USER_HOME/.scripts/install/install.sh
