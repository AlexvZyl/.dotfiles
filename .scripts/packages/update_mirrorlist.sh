#!/bin/bash
sudo reflector --download-timeout 30 --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
