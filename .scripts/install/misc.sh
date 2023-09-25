#!/bin/bash

source "$(dirname $0)/../utils.sh"

# Cron.
crontab $USER_HOME/.config/cron/crontab
sudo systemctl enable cronie

# Enable SysRq keys.
sudo touch /etc/sysctl.d/99-sysctl.conf
sudo sh -c "echo 'kernel.sysrq=1' >> /etc/sysctl.d/99-sysctl.conf"

# Add bnaries to sudoers.
sudo sh -c "echo '$USER ALL = NOPASSWD: /usr/bin/s-tui, /usr/bin/pacman, /usr/bin/fail2ban' >> /etc/sudoers"
