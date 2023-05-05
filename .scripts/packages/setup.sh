#!/bin/bash

# Install yay.
git clone https://aur.archlinux.org/yay.git ~/Repositories/yay/
cd ~/Repositories/yay/ || exit
makepkg -si
cd ~ || exit

~/.scripts/packages/update_mirrorlist.sh
~/.scripts/packages/install.sh
