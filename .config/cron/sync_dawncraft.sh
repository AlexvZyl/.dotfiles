#!/bin/bash

CUR_PATH=$(dirname "$0")
source "$CUR_PATH/env.sh"

notify-send "󰚩  DawnCraft Server" "Starting sync..."
RESULT=$(rsync -avz -e ssh DawnCraft-Server:/home/mc-server/minecraft-server/data/simplebackups/ $HOME/DawnCraft/)
notify-send "󰚩  DawnCraft Server" "Finished sync."
notify-send --urgency=debug "DawnCraft Server" "$RESULT"
