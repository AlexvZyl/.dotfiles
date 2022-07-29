#!/bin/bash

# Ensure submodules are updated.
git submodule update

# Make the function keys on the keyboard default.
# (This is currently specific to my keychron keyboard)
FILE=/etc/modprobe.d/hid_apple.conf
sudo touch $FILE
sudo sh -c "echo 'options hid_apple fnmode=2' >> $FILE"

# Use yay to get pamac (installed by default on EndeavourOS).
# yay -S libpamac-aur pamac-all # The full version is not currently building.
yay -S libpamac-aur pamac-aur

# Browser.
sudo pamac install --no-confirm brave-bin 
sudo pamac remove firefox --no-confirm

# Office.
sudo pamac install onlyoffice-bin --no-confirm

# Fonts.  This is very large, maybe use smaller package.
sudo pamac install nerd-fonts-complete --no-confirm

# Icons.
sudo pamac install papirus-icon-theme --no-confirm

# Required for Gnome extensions.
sudo pamac install gnome-browser-connector --no-confirm

# Terminal.
sudo pamac install alacritty --no-confirm

# Coding stuff.
sudo pamac install neovim --no-confirm
sudo pamac install neovide --no-confirm
# Install plugin for nvim.
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
sudo pamac install github-desktop --no-confirm
sudo pamac install code --no-confirm

# Communication.
sudo pamac install whatsapp-nativefier discord signal-desktop --no-confirm

# Programming languages.
sudo pamac install julia-bin --no-confirm

# Setup fish (shell).
sudo pamac install fish --no-confirm
fish <<'END_FISH'
	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
	fisher install IlanCosman/tide@v5t
END_FISH

# Copy data over.
# For now I do not want the home directory to be a git repo, so copy the relevant folders over.
rsync -a -r .config/ ~/.config/
rsync -a -r .local/ ~/.local/
rsync -a -r .profile ~/.profile
