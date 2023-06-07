#!/bin/bash

CUR_PATH=$(dirname "$0")
source "$CUR_PATH/env.sh"

notify-send "󰚩  DawnCraft Server" "Starting sync..."

RESULT=$(rsync -avz -e ssh DawnCraft-Server:/home/mc-server/minecraft-server/data/simplebackups/ $HOME/DawnCraft/simplebackups)
notify-send --urgency=debug "DawnCraft Server" "$RESULT"
RESULT=$(rsync -avz -e ssh DawnCraft-Server:/home/mc-server/minecraft-server/data/world/ $HOME/DawnCraft/world)
notify-send --urgency=debug "DawnCraft Server" "$RESULT"

notify-send "󰚩  DawnCraft Server" "Finished sync."

