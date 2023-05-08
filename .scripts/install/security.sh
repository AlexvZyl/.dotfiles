#!/bin/bash

# ufw
sudo systemctl enable ufw.service
sudo systemctl start ufw.service
sudo ufw enable 

# fail2ban
sudo systemctl enable fail2ban.service
sudo systemctl start fail2ban.service
sudo fail2ban-client start

# clamav 
sudo systemctl enable clamav-freshclam.service
sudo systemctl start clamav-freshclam.service
