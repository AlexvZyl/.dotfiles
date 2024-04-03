#!/bin/sh
tmux list-sessions -F "#S" | grep '[^0-9]'
