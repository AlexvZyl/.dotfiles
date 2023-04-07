#!/bin/bash

# Bootloader.
sudo pamac install refind --no-confirm
refind-install
sudo chmod +x ~/.scripts/setup_refind.sh && ~/.scripts/setup_refind.sh
