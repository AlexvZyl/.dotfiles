#!/bin/bash

source "$(dirname $0)/../utils.sh"

ln -f -s "$USER_HOME/.etc/pacman.conf" "/etc/pacman.conf"
ln -f -s "$USER_HOME/.etc/sddm.conf" "/etc/sddm.conf"

rm -rdf "$USER_HOME/.ssh"
ln -f -s -d "$USER_HOME/.private/.ssh/" "$USER_HOME/"