#!/bin/bash

source "env.sh"
notify-send "DawnCraft Server" " 󰚩  Starting sync... "
RESULT=$(rsync -avz -e ssh DawnCraft-Server:/home/mc-server/minecraft-server/data/simplebackups/ $HOME/DawnCraft/)
notify-send "DawnCraft Server" " 󰚩  Finished sync. "
notify-send --urgency=debug "DawnCraft Server" " $RESULT "
