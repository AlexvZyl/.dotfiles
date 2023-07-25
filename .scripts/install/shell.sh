#!/bin/bash

fish <<'END_FISH'
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fisher install IlanCosman/tide@v5t
    echo "3\
          2\
          2\
          4\
          4\
          5\
          2\
          2\
          2\
          2\
          2\
          y\
         " | tide configure
END_FISH
