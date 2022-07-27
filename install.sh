# Install Nerd Fonts.
sudo pamac install nerd-fonts-complete

# Setup alacritty.
sudo pamac install alacritty

# Setup fish.
sudo pamac install fish
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install IlanCosman/tide@v5
tide configure
