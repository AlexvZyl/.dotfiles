#!/bin/bash

source "$(dirname $0)/../utils.sh"

sudo rm -rdf "$USER_HOME/.ssh"
sudo ln -f -s -d "$USER_HOME/.private/.ssh/" "$USER_HOME/"

sudo rm /etc/nixos/configuration.nix
sudo ln -f -s "$USER_HOME/.config/nixos/configuration.nix" "/etc/nixos/configuration.nix"
