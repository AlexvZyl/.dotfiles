#!/bin/bash

source "$(dirname $0)/../utils.sh"

# Make the function keys on the keyboard default over media keys.
# (This is currently specific to my keychron keyboard)
FILE=/etc/modprobe.d/hid_apple.conf
sudo touch $FILE
sudo sh -c "echo 'options hid_apple fnmode=2' >> $FILE"

# Bluetooth.
systemctl enable bluetooth.service
systemctl restart bluetooth.service
sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf # Enable on startup.

# Sound stuff.
# Prevent the crackling sound.
sudo sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=0/g' /etc/pulse/default.pa

# Power management.
systemctl enable tlp.service
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket
systemctl start tlp.service
sudo tlp start

# Setup optimus manager.
if $NVIDIA_GPU; then
    sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm/custom.conf
    sudo touch /etc/optimus-manager/optimus-manager.conf 
    sudo sh -c "echo '[optimus]' >> /etc/optimus-manager/optimus-manager.conf" 
    sudo sh -c "echo 'startup_mode=nvidia' >> /etc/optimus-manager/optimus-manager.conf" 
    systemctl enable optimus-manager
    systemctl start optimus-manager &
fi
