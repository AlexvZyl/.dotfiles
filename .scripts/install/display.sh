#!/bin/bash

source "$(dirname $0)/../utils.sh"

# SDDM Login Manager
sudo systemctl disable display-manager
sudo systemctl enable sddm

# Nordic
# sudo cp $USER_HOME/.wallpapers/National_Park_Nord.png /usr/share/sddm/themes/sugar-candy/Backgrounds/Mountains.jpg

# Tokyonight
sudo cp $USER_HOME/.wallpapers/Tokyonight_Street_1.png /usr/share/sddm/themes/sugar-candy/Backgrounds/Mountains.jpg

# Setup lock screen.
# Should this script run every time the screens change?  Yeah.

# Nordic
# betterlockscreen -u $USER_HOME/.wallpapers/National_Park_Nord.png --display 1
# betterlockscreen -u $USER_HOME/.wallpapers/National_Park_Nord.png --blur 0.5 --display 1

# Tokyonight
betterlockscreen -u $USER_HOME/.wallpapers/Tokyonight_Street_1.png --display 1
betterlockscreen -u $USER_HOME/.wallpapers/Tokyonight_Street_1.png --blur 0.5 --display 1
