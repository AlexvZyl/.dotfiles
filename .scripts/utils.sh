#!/bin/bash

if [ -z ${SUDO_USER} ]; then
    export USER_HOME="$HOME"
else
    export USER_HOME="/home/${SUDO_USER}"
fi

if lspci | grep -i NVIDIA &>/dev/null; then
    export NVIDIA_GPU=true
else
    export NVIDIA_GPU=false
fi
