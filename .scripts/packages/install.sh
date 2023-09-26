#!/bin/bash

source "$(dirname $0)/../utils.sh"

yay -S $(cat $USER_HOME/.scripts/packages/CORE.txt)
if $NVIDIA_GPU; then
    yay -S $(cat $USER_HOME/.scripts/packages/NVIDIA.txt)
fi

gh extension install dlvhdr/gh-dash
