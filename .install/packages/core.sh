#!/bin/bash
# Everything that is essential, regardless of hardware and use case.

# Ensure packages are up to date.
sudo pacman -Syu

# Essentials.
sudo pacman -S git base-devel gum

# Install yay.
git clone https://aur.archlinux.org/yay.git ~/GitHub/yay/
cd ~/GitHub/yay/ && makepkg -si && cd ~

# Use yay to get pamac.
# yay -S libpamac-full pamac-all # Support for snap and flatpak.
yay -S libpamac-aur pamac-aur # Only AUR.
sudo pacman -Syu polkit-gnome
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
sudo sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

# Browser.
# Keep firefox since some programs use it by default (for example cargo).
sudo pamac install firefox brave-bin --no-confirm

# Office.
sudo pamac install onlyoffice-bin xournalpp --no-confirm

# Fonts.
sudo pamac install nerd-fonts-jetbrains-mono --no-confirm

# Terminal.
sudo pamac install alacritty --no-confirm

# Gnome stuff.
sudo pamac install gnome-browser-connector gnome-tweaks --no-confirm

# i3 stuff.
sudo pamac install feh xborder-git cronie rofi rofi-greenclip picom --no-confirm
chmod +x ~/.config/picom/scripts/toggle-picom-inactive-opacity.sh
# Stuff for polybar.
chmod +x ~/.config/polybar.personal/scripts/check-read-mode-status.sh
sudo pamac install polybar python-pywal pywal-git networkmanager-dmenu-git calc --no-confirm

# Install s-tui and set to run as admin.
sudo pamac install s-tui --no-confirm

# Add bnaries to sudoers.
sudo sh -c "echo 'alex ALL = NOPASSWD: /usr/bin/s-tui, /usr/bin/pacman' > /etc/sudoers"

# Enable SysRq keys.
sudo touch /etc/sysctl.d/99-sysctl.conf
sudo sh -c "echo 'kernel.sysrq=1' >> /etc/sysctl.d/99-sysctl.conf"

# Manuals.
sudo pamac install man-db --no-confirm

# Some aesthetic stuff.
sudo pamac install cmatrix bonsai.sh-git pipes.sh lolcat shell-color-scripts --no-confirm

# Utilities.
sudo pamac install scrot zathura zathura-pdf-mupdf-git cpu-x fuse-common powertop speedtest-cli gnome-calculator balena-etcher btop nvtop thunar lazygit flameshot brightnessctl pfetch bottom dunst --no-confirm

# Icons.
sudo pamac install papirus-icon-theme --no-confirm

# GUI stuff.
sudo pamac install lxappearance-gtk3 gruvbox-material-gtk-theme-git gtk-theme-material-black --no-confirm

# SDDM Login Manager
sudo pamac install sddm sddm-sugar-dark sddm-sugar-candy-git archlinux-tweak-tool-git --no-confirm
sudo systemctl disable display-manager && sudo systemctl enable sddm
sudo touch /etc/sddm.conf
sudo sh -c "echo '[Theme]' >> /etc/sddm.conf"
sudo sh -c "echo 'Current=sugar-candy' >> /etc/sddm.conf"
sudo cp ~/.wallpapers/mountain_jaws.jpg /usr/share/sddm/themes/sugar-candy/
sudo mv /usr/share/sddm/themes/sugar-candy/mountain_jaws.jpg /usr/share/sddm/themes/sugar-candy/wall_secondary.png

# Media.
sudo pamac install playerctl --no-confirm

# Install lock screen.
sudo pamac install betterlockscreen-git --no-confirm
# Setup lock screen.
# Should this script run every time the screens change?  Yeah.
# betterlockscreen -u ~/.wallpapers/forest-mountain-cloudy-valley.png --blur 0.5
# betterlockscreen -u ~/.wallpapers/misty_mountains.jpg --blur 0.5
betterlockscreen -u ~/.wallpapers/mountain_jaws.jpg --blur 0.5
betterlockscreen -u ~/.wallpapers/mountain_jaws.jpg
