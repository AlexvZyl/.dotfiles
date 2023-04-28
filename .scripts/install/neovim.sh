#!/bin/bash

WORK_TREE="$HOME"
NVIM_DIR="$WORK_TREE/.config/nvim"
NVIM_BACKUP="$NVIM_DIR.backup"
GIT_DIR="$NVIM_DIR/.git"
SPARSE_FILE="$GIT_DIR/info/sparse-checkout"

if [ -d $NVIM_BACKUP ]; then
    echo "\"$NVIM_BACKUP\" is not empty, since a backup has already been made.  The script is stopping, as I do not want to accidentally overwrite your configs.  Please rename or delete this directory."
    exit 0
fi

if [ -d $NVIM_DIR ]; then
    echo "Creating a backup of \"$NVIM_DIR\" at \"$NVIM_BACKUP\"."
    mv "$NVIM_DIR" "$NVIM_BACKUP"
fi

mkdir -p "$GIT_DIR"
cd "$GIT_DIR" || exit
git init --bare
git remote add -f origin https://github.com/AlexvZyl/.dotfiles

git config core.sparseCheckout true
touch "$SPARSE_FILE"
echo ".config/nvim/*" >> "$SPARSE_FILE"

git --work-tree=$WORK_TREE --git-dir=$GIT_DIR checkout main
git --work-tree=$WORK_TREE --git-dir=$GIT_DIR pull --depth=1 origin main
