#!/bin/bash

source "$(dirname $0)/../utils.sh"

# Install yay.
rm -rdf $USER_HOME/.modules/yay/
git clone https://aur.archlinux.org/yay.git $USER_HOME/.modules/yay/
cd $USER_HOME/.modules/yay/ || exit
makepkg -si
cd $USER_HOME || exit

# Keys.
yay -S archlinux-keyring
sudo pacman-key --init
sudo pacman-key --populate archlinux

# Mirrors.
yay -Syyu reflector rsync
$USER_HOME/.scripts/packages/update_mirrorlist.sh &

# Packages.
$USER_HOME/.scripts/packages/install.sh
