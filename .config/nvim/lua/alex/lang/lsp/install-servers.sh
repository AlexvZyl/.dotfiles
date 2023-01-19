#!/bin/bash

# Ensure packages are up to date.
yay -Syyu

# Lua (by sumneko)
yay -S lua-language-server

# Julia uses the executable with added packages.
yay -S julia-bin

# Bash.
yay -S bash-language-server

# Python.
yay -S pyright

# Rust.
yay -S rust-analyzer

# LaTeX.
yay -S texlab

# C++.
yay -S ccls

# CMake.
yay -S cmake-language-server
pip install cmake-language-server

# Json.
yay -S vscode-json-languagese
