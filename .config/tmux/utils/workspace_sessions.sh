#!/bin/bash
tmux list-sessions -F "#S" | grep '[^0-9]'
