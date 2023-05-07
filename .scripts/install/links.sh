#!/bin/bash

sudo ln -f -s "${HOME}/.etc/pacman.conf" "/etc/pacman.conf"
sudo ln -f -s "${HOME}/.etc/sddm.conf" "/etc/sddm.conf"
sudo ln -f -s -d "${HOME}/.private/.ssh/" "$HOME/.ssh/"
