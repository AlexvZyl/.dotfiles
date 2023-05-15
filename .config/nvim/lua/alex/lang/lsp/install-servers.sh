#!/bin/bash

# Ensure packages are up to date.
yay -Syyu

yay -S lua-language-server
yay -S julia-bin
yay -S bash-language-server
yay -S pyright
yay -S rust-analyzer
yay -S texlab
yay -S ccls
yay -S cmake-language-server
pip install cmake-language-server
yay -S vscode-json-languagese
yay -S yaml-language-server
