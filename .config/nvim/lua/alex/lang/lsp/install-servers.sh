#!/bin/bash

# Ensure packages are up to date.
yay -Syyu

# Install lsps.
yay -S  lua-language-server     \
        julia-bin               \
        bash-language-server    \
        pyright                 \
        rust-analyzer           \
        texlab                  \
        ccls                    \
        cmake-language-server   \
        vscode-json-languagese  \
        yaml-language-server
