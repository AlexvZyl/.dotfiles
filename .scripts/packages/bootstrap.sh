#!/bin/bash

# Install yay.
rm -rdf ~/.modules/yay/
git clone https://aur.archlinux.org/yay.git ~/.modules/yay/
cd ~/.modules/yay/ || exit
makepkg -si
cd ~ || exit

# Update and install.
yay -Syyu reflector rsync
~/.scripts/packages/update_mirrorlist.sh
~/.scripts/packages/install.sh
