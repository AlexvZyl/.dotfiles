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

The entire colorscheme is based on [Gruvbox Material](https://github.com/sainnhe/gruvbox-material).  I have not been able to find a nicer colorscheme.

## Desktop

Unsure to whom the wallpaper credits belongs to.

<br/>

![image](https://user-images.githubusercontent.com/81622310/210166420-bd058369-8ac0-41f6-8c28-e179a640c03b.png)

## Polybar

*TODO*

## Read mode

`Super + r` disables the `inactive-opacity` (from `picom`) for when readability is important.  An indicator is displayed via polybar.

<br/>

![image](https://user-images.githubusercontent.com/81622310/210166518-81c9b3a0-3725-47ad-85ac-13867603d344.png)

![image](https://user-images.githubusercontent.com/81622310/210166538-2f667f2f-187e-4cd3-8151-532eaa9f413a.png)

## Neovim

The [Neovim config](https://github.com/Alex-vZyl/.dotfiles/tree/main/.config/nvim) has a decent amount of work and is very close to a proper IDE.  Why didn't I use [LunarVim](https://github.com/LunarVim/LunarVim), [NvChad](https://github.com/NvChad/NvChad) or [SpaceVim](https://github.com/liuchengxu/space-vim)?  I like doing things myself. 

<br/>

![image](https://user-images.githubusercontent.com/81622310/209938372-1b6a067c-ca5f-4d10-8420-6c4d244a048d.png)

![image](https://user-images.githubusercontent.com/81622310/210166463-0374ec98-fd0b-4e6c-8397-0c467c67a387.png)

![image](https://user-images.githubusercontent.com/81622310/210166474-ed770e33-6b59-4646-8cbf-63be00779ea6.png)

![image](https://user-images.githubusercontent.com/81622310/210166469-96022383-f06a-4af0-9358-119b6a4e3277.png)
