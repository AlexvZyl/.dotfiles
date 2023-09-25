#!/bin/bash

if [ -z ${SUDO_USER} ]
then
    export USER_HOME="$HOME"
else
    export USER_HOME="/home/${SUDO_USER}"
fi