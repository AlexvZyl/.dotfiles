#!/bin/bash

# Everything related to the fish shell.

# Install the fish shell.
sudo pamac install fish --no-confirm

# Install and setup tide.
fish <<'END_FISH'
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    fisher install IlanCosman/tide@v5t
    echo "3\
          2\
          2\
          4\
          4\
          5\
          2\
          1\
          1\
          2\
          2\
          y\
         " | tide configure
END_FISH
