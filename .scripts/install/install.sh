#!/bin/bash

source "$(dirname $0)/../utils.sh"

$USER_HOME/.scripts/install/dual-boot.sh
$USER_HOME/.scripts/install/links.sh
$USER_HOME/.scripts/install/display.sh
$USER_HOME/.scripts/install/hardware.sh
$USER_HOME/.scripts/install/misc.sh
$USER_HOME/.scripts/install/security.sh


$USER_HOME/.tmux/plugins/tpm/tpm
$USER_HOME/.tmux/plugins/tpm/bin/install_plugins
