#!/bin/bash

sudo pamac install refind --no-confirm
refind-install
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/bobafetthotmail/refind-theme-regular/master/install.sh)"
