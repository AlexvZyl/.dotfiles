#!/bin/bash

# TODO(alex): Which of these can be done with Nix?

# Get user.
if [ -z "${SUDO_USER}" ]
then
    export USER_HOME="$HOME"
else
    export USER_HOME="/home/${SUDO_USER}"
fi

# Clone and build
nix-env --install git

mkdir ~/.dotfiles
git --git-dir="$USER_HOME/.dotfiles/" --work-tree="$USER_HOME" clone --bare https://github.com/AlexvZyl/.dotfiles "$USER_HOME/.dotfiles/"
git --git-dir="$USER_HOME/.dotfiles/" --work-tree="$USER_HOME" checkout -f

source "$USER_HOME/.profile"
nix-build

# Setup GitHub.
gh auth login
gh extension install dlvhdr/gh-dash
config config --local status.showUntrackedFiles no
git config --global user.email "alexandervanzyl@protonmail.com"
git config --global user.name "AlexvZyl"

# Get modules.
config submodule update --init --force --remote .password-store/
config submodule update --init --force --remote .private/
config submodule update --init --force --remote .modules/user.js/
config submodule update --init --force --remote .config/nvim/
config submodule update --init --force --remote .tmux/plugins/tpm

# Setup ssh.
sudo rm -rdf "$USER_HOME/.ssh"
sudo ln -f -s -d "$USER_HOME/.private/.ssh/" "$USER_HOME/"
chmod +x 600 ~/.ssh/

# Tmux
"$USER_HOME/.tmux/plugins/tpm/bin/install_plugins"

config config pull.rebase=true
config config remote.origin.url=git@github.com:AlexvZyl/.dotfiles.git
