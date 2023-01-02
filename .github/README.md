# .dotfiles

The configuration files for my Linux desktop.  Supports Arch based distros using Gnome and/or i3.  Also, currently it assumes you have an Nvidia GPU and Intel CPU.

# Installation

To install everything, simply copy and paste this into the terminal.  Reboot after it is done.

> _⚠️ &nbsp; I am not following proper development protocol, so this might not always be stable._

```bash
sudo pacman -S git
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
mkdir ~/.dotfiles
config clone --bare https://github.com/AlexvZyl/.dotfiles ~/.dotfiles/
config checkout -f
sudo chmod +x ~/.scripts/install.sh && ~/.scripts/install.sh
```

# Overview

Some screenshots showing of the desktop and rice, as well as some custom features I wrote.  Everything has to be *just right*.  I am spending 8+ hours a day on this working, so it might as well be a nice experience.

## Desktop

Wallpapers can be found [here](https://github.com/linuxdotexe/nordic-wallpapers).  They "norded" some nice wallpapers.

![image](https://user-images.githubusercontent.com/81622310/210185859-64ebd7c0-1248-4a2a-bc00-75975a7ab07f.png)

![image](https://user-images.githubusercontent.com/81622310/210213672-4ceccf4e-8cf6-4c33-8883-9e3e887f9e58.png)

![image](https://user-images.githubusercontent.com/81622310/210213702-c6308ecd-8b7c-42d4-a517-1b16b3e7d2dc.png)

![image](https://user-images.githubusercontent.com/81622310/210214086-2cd8cfb8-9fc1-43e8-b973-8763d9bed4fc.png)

## Polybar

*TODO*

## Read mode

`Super + r` disables the `inactive-opacity` (from `picom`) for when readability is important.  An indicator is displayed via polybar.

<br/>

## Neovim

The [Neovim config](https://github.com/Alex-vZyl/.dotfiles/tree/main/.config/nvim) has a decent amount of work and is very close to a proper IDE.  Why didn't I use [LunarVim](https://github.com/LunarVim/LunarVim), [NvChad](https://github.com/NvChad/NvChad) or [SpaceVim](https://github.com/liuchengxu/space-vim)?  I like doing things myself. 

<br/>


