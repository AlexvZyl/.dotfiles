#!/bin/bash

ln -f -s "$HOME/.etc/pacman.conf" "/etc/pacman.conf"
ln -f -s "$HOME/.etc/sddm.conf" "/etc/sddm.conf"

rm -rdf "$HOME/.ssh"
ln -f -s -d "$HOME/.private/.ssh/" "$HOME/"
