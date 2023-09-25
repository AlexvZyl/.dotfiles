#!/bin/bash

source "$(dirname $0)/../utils.sh"

# SDDM Login Manager
sudo systemctl disable display-manager
sudo systemctl enable sddm
sudo cp $USER_HOME/.wallpapers/National_Park_Nord.png /usr/share/sddm/themes/sugar-candy/
sudo mv /usr/share/sddm/themes/sugar-candy/National_Park_Nord.png /usr/share/sddm/themes/sugar-candy/wall_secondary.png

# Setup lock screen.
# Should this script run every time the screens change?  Yeah.
betterlockscreen -u $USER_HOME/.wallpapers/National_Park_Nord.png --display 1
betterlockscreen -u $USER_HOME/.wallpapers/National_Park_Nord.png --blur 0.5 --display 1
