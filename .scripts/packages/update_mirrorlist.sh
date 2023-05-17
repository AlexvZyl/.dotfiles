#!/bin/bash

PROTOCOL=https
COUNT=20

echo "Finding the $COUNT fastest $PROTOCOL mirrors.  This can take a few minutes..."
sudo reflector --download-timeout 30 --latest $COUNT --protocol $PROTOCOL --sort rate --save /etc/pacman.d/mirrorlist
