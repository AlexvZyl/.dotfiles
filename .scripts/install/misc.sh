#!/bin/bash

# Cron.
crontab ~/.config/cron/crontab
sudo systemctl enable cronie

# Enable SysRq keys.
sudo touch /etc/sysctl.d/99-sysctl.conf
sudo sh -c "echo 'kernel.sysrq=1' >> /etc/sysctl.d/99-sysctl.conf"

# Add bnaries to sudoers.
sudo sh -c "echo 'alex ALL = NOPASSWD: /usr/bin/s-tui, /usr/bin/pacman' > /etc/sudoers"

# Links.
sudo ln -f -s "${HOME}/.etc/pacman.conf" "/etc/pacman.conf"
sudo ln -f -s "${HOME}/.etc/sddm.conf" "/etc/sddm.conf"
