#!/bin/bash

source "$(dirname $0)/../utils.sh"

sudo ln -f -s "$USER_HOME/.etc/pacman.conf" "/etc/pacman.conf"
sudo ln -f -s "$USER_HOME/.etc/sddm.conf" "/etc/sddm.conf"

sudo rm -rdf "$USER_HOME/.ssh"
sudo ln -f -s -d "$USER_HOME/.private/.ssh/" "$USER_HOME/"
