# Use yay to get pacac.  yay is installed by default on EndeavourOS.
# yay -S libpamac-aur pamac-all # The full version is not currently building.
yay -S libpamac-aur pamac-aur

# Browser.
sudo pamac install brave-bin
sudo pamac remove firefox

# Install Nerd Fonts.
sudo pamac install nerd-fonts-complete

# Icons.  Has to be added in tweaks.
sudo pamac install papirus-icon-theme

# Setup alacritty.
sudo pamac install alacritty

# Setup fish.
sudo pamac install fish
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install IlanCosman/tide@v5
tide configure
