#!/bin/bash

# Pacman.
sudo ln -f -s "${HOME}/.etc/pacman.conf" "/etc/pacman.conf"

# SDM login.
sudo ln -f -s "${HOME}/.etc/sddm.conf" "/etc/sddm.conf"
