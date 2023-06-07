#!/bin/bash

CUR_PATH=$(dirname "$0")
source "$CUR_PATH/env.sh"

notify-send "󰚩  DawnCraft Server" "Starting sync..."

SIZE=$(rsync -avz -e ssh DawnCraft-Server:/home/mc-server/minecraft-server/data/simplebackups/ $HOME/DawnCraft/simplebackups | grep "total size")
notify-send "󰚩  DawnCraft Server" "$SIZE"
SIZE=$(rsync -avz -e ssh DawnCraft-Server:/home/mc-server/minecraft-server/data/world/ $HOME/DawnCraft/world | grep "total size")
notify-send "󰚩  DawnCraft Server" "$SIZE"

notify-send "󰚩  DawnCraft Server" "Finished sync."

