#!/bin/sh

source "$(dirname $0)/../utils.sh"

# Cron.

# Add bnaries to sudoers.
sudo sh -c "echo '$USER ALL = NOPASSWD: /usr/bin/s-tui, /usr/bin/pacman, /usr/bin/fail2ban-client' >> /etc/sudoers"

