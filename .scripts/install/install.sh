#!/bin/bash

# Ensure packages and mirrorlist are up to date.
sudo pacman -Syyu
~/.scripts/install/update_pacman_mirrorlist.sh

# Install yay.
git clone https://aur.archlinux.org/yay.git ~/GitHub/yay/
cd ~/GitHub/yay/ && makepkg -si && cd ~

# Install packages.
sudo pacman -S --needed - < ~/.scripts/install/packages.txt

# i3 stuff.
chmod +x ~/.config/picom/scripts/toggle-picom-inactive-opacity.sh

# Polybar.
chmod +x ~/.config/polybar.personal/scripts/check-read-mode-status.sh

# Prevent the crackling sound.
sudo sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=0/g' /etc/pulse/default.pa

# Enable SysRq keys.
sudo touch /etc/sysctl.d/99-sysctl.conf
sudo sh -c "echo 'kernel.sysrq=1' >> /etc/sysctl.d/99-sysctl.conf"

# Add bnaries to sudoers.
sudo sh -c "echo 'alex ALL = NOPASSWD: /usr/bin/s-tui, /usr/bin/pacman' > /etc/sudoers"

# Setup github.
sudo chmod +x ~/.scripts/install/git.sh && sudo ~/.scripts/install/git.sh

# Install language servers.
sudo chmod +x ~/.config/nvim/lua/alex/lang/lsp/install-servers.sh && ~/.config/nvim/lua/alex/lang/lsp/install-servers.sh

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
~/.scripts/install/refind.sh
