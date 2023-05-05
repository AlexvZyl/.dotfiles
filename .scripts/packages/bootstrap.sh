#!/bin/bash

# Install yay.
cd ~/.modules/yay/ || exit
makepkg -si
cd ~ || exit

# Update system.
yay -Syyu

# Install packages.
yay -S reflector rsync
~/.scripts/packages/update_mirrorlist.sh
~/.scripts/packages/install.sh
