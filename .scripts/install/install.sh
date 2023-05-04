#!/bin/bash

# First install all packages and yay.
~/.scripts/packages/setup.sh

# i3 stuff.
chmod +x ~/.config/picom/scripts/toggle-picom-inactive-opacity.sh

# Polybar.
chmod +x ~/.config/polybar.personal/scripts/check-read-mode-status.sh

# Enable SysRq keys.
sudo touch /etc/sysctl.d/99-sysctl.conf
sudo sh -c "echo 'kernel.sysrq=1' >> /etc/sysctl.d/99-sysctl.conf"

# Add bnaries to sudoers.
sudo sh -c "echo 'alex ALL = NOPASSWD: /usr/bin/s-tui, /usr/bin/pacman' > /etc/sudoers"

# SDDM Login Manager
sudo pamac install sddm sddm-sugar-dark sddm-sugar-candy-git archlinux-tweak-tool-git --no-confirm
sudo systemctl disable display-manager && sudo systemctl enable sddm
sudo touch /etc/sddm.conf
sudo cp ~/.wallpapers/National_Park_Nord.png /usr/share/sddm/themes/sugar-candy/
sudo mv /usr/share/sddm/themes/sugar-candy/National_Park_Nord.png /usr/share/sddm/themes/sugar-candy/wall_secondary.png

# Setup lock screen.
# Should this script run every time the screens change?  Yeah.
betterlockscreen -u ~/.wallpapers/National_Park_Nord.png --display 1
betterlockscreen -u ~/.wallpapers/National_Park_Nord.png --blur 0.5 --display 1

# Run other scripts.
~/.scripts/install/dual-boot.sh
~/.scripts/install/fish.sh
~/.scripts/install/git.sh
~/.scripts/install/hardware.sh
~/.scripts/install/links.sh
~/.scripts/install/cron.sh
~/.tmux/plugins/tpm/bin/install_plugins
~/.config/nvim/lua/alex/lang/lsp/install-servers.sh
