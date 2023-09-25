#!/bin/bash

# ufw
(
	sudo systemctl enable ufw.service
	sudo systemctl start ufw.service
	sudo ufw enable
) &

# fail2ban
(
	sudo systemctl enable fail2ban.service
	sudo systemctl start fail2ban.service
	sudo fail2ban-client start
	sudo fail2ban-client add sshd 
) &

# clamav 
(
	sudo systemctl enable clamav-freshclam.service
	sudo systemctl start clamav-freshclam.service
) &

# Tor.
(
	sudo systemctl enable tor.service
	sudo systemctl start tor.service
) &

# Proxy.
(
	sudo systemctl enable privoxy.service
	sudo systemctl start privoxy.service
) &
