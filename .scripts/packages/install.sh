#!/bin/bash

source "$(dirname $0)/../utils.sh"

yay -S $(cat $USER_HOME/.scripts/packages/CORE.txt)
