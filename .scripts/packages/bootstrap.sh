#!/bin/bash

# Install yay.
rm -rdf ~/.modules/yay/
git clone https://aur.archlinux.org/yay.git ~/.modules/yay/
cd ~/.modules/yay/ || exit
makepkg -si
cd ~ || exit

# Keys.
yay -S archlinux-keyring
sudo pacman-key --init
sudo pacman-key --populate archlinux

# Mirrors.
yay -Syyu reflector rsync
echo "Finding the best mirrors.  This can take a few minutes..."
~/.scripts/packages/update_mirrorlist.sh

# Packages.
~/.scripts/packages/install.sh
