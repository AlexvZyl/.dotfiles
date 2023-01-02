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

*Just the desktop:*
![image](https://user-images.githubusercontent.com/81622310/210185859-64ebd7c0-1248-4a2a-bc00-75975a7ab07f.png)

*Notifications via [dunst](https://github.com/dunst-project/dunst):*
![image](https://user-images.githubusercontent.com/81622310/210214740-3056d03c-40d0-430b-b35d-3f1d8607334f.png)

*Launcher via [rofi](https://github.com/adi1090x/rofi):*
![image](https://user-images.githubusercontent.com/81622310/210214442-777ef32e-52e9-4810-8196-20da4e012b8d.png)

*Powermenu via [rofi](https://github.com/adi1090x/rofi):*
![image](https://user-images.githubusercontent.com/81622310/210214497-bd4053ba-81d1-4a8e-b44e-033450f50025.png)

*Lock screen via [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen):*
![image](https://user-images.githubusercontent.com/81622310/210214086-2cd8cfb8-9fc1-43e8-b973-8763d9bed4fc.png)

## Polybar

*TODO*

## Read mode

`Super + r` disables the `inactive-opacity` (from `picom`) for when readability is important.  An indicator is displayed via polybar.

<br/>

## Neovim

The [Neovim config](https://github.com/Alex-vZyl/.dotfiles/tree/main/.config/nvim) has a decent amount of work and is very close to a proper IDE.  Why didn't I use [LunarVim](https://github.com/LunarVim/LunarVim), [NvChad](https://github.com/NvChad/NvChad) or [SpaceVim](https://github.com/liuchengxu/space-vim)?  I like doing things myself. 

<br/>


