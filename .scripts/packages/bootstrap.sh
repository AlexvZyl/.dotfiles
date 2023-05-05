#!/bin/bash

# Install yay.
rm -rdf ~/Repositories/yay/
git clone https://aur.archlinux.org/yay.git ~/Repositories/yay/
cd ~/Repositories/yay/ || exit
makepkg -si
cd ~ || exit

# Update system.
yay -Syyu

# Install packages.
~/.scripts/packages/update_mirrorlist.sh
~/.scripts/packages/install.sh
