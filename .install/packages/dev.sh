#!/bin/bash

# Coding stuff.
sudo pamac install neovim ripgrep neovide xclip nvim-packer-git --no-confirm
sudo pamac install nodejs github-desktop github-cli code --no-confirm

# Programming.
sudo pamac install julia-bin emf-langserver cmake python --no-confirm

# Setup github.
sudo chmod +x ~/.scripts/setup_git.sh && sudo ~/.scripts/setup_git.sh

# Install language servers.
sudo chmod +x ~/.config/nvim/lua/alex/lang/lsp/install-servers.sh
