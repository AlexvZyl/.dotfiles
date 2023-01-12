# .dotfiles

The configuration files for my Linux desktop.  Supports Arch based distros using Gnome and/or i3.  Also, currently it assumes you have an Nvidia GPU and Intel CPU.

I mainly use i3, but I also install Gnome for when people do not want to mess around with a tiling WM.  All of the screenshots are for i3 and the gnome configs are very basic.  

> _ℹ️ &nbsp; Remember to choose i3 at the login screen._

> _⚠️ &nbsp; These are my personal dotfiles, which means they will continuously change.  If you came here from a reddit post and it is no longer like in the post, that is why._

# Installation

To install everything, simply copy and paste this into the terminal.  Reboot after it is done.

> _⚠️ &nbsp; I am not following proper development protocol, so this might not always be stable._

> _⚠️ &nbsp; This forces a checkout, which can ruin existing configs.  Better to use on a clean install._

```bash
sudo pacman -S git
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
mkdir ~/.dotfiles
config clone --bare https://github.com/AlexvZyl/.dotfiles ~/.dotfiles/
config checkout -f
sudo chmod +x ~/.scripts/install.sh && ~/.scripts/install.sh
```

*Currently working on an install utility:*
![TUI_Preview](https://user-images.githubusercontent.com/81622310/211422167-be097846-014b-47d0-be45-dac8872ae327.gif)

# Showcase

Some screenshots showing of the desktop and rice, as well as some custom features I wrote.  Everything has to be *just right*.  I am spending 8+ hours a day on this working, so it might as well be a nice experience.

## Overview

Wallpapers can be found at [this ImageGoNord repo](https://github.com/linuxdotexe/nordic-wallpapers) and [locally](https://github.com/AlexvZyl/.dotfiles/tree/main/.wallpapers).  They "norded" some nice wallpapers.

*For Reddit:*

![image](https://user-images.githubusercontent.com/81622310/210989596-85191ac2-2047-4294-b170-c40ff8c42b09.png)

![image](https://user-images.githubusercontent.com/81622310/211797435-787fd312-e2fa-4480-b8e9-884a69d445ca.png)

![image](https://user-images.githubusercontent.com/81622310/211798157-7aed7f58-6898-4427-a848-404a0f7dbee0.png)

*Notifications via [dunst](https://github.com/dunst-project/dunst):*
![image](https://user-images.githubusercontent.com/81622310/210980911-cb7825d5-1ac2-4db9-b34a-f92887701d1d.png)

*Launcher via [rofi](https://github.com/adi1090x/rofi):*
![image](https://user-images.githubusercontent.com/81622310/211895894-663f3480-d2d9-4546-8f1b-04217cb2dd75.png)

*Powermenu via [rofi](https://github.com/adi1090x/rofi):*
![image](https://user-images.githubusercontent.com/81622310/211911407-050741e9-d7d7-412c-ac12-044f002e8b6f.png)

*Lock screen via [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen):*
![image](https://user-images.githubusercontent.com/81622310/211187368-5d8e1215-4482-4506-9cd9-6508d980f1f3.png)

## Polybar

*TODO*

### References

- [Arcolinux](https://github.com/arcolinux/arcolinux-polybar/blob/master/etc/skel/.config/polybar/config)
- [Polybar-Themes](https://github.com/adi1090x/polybar-themes)

## Read mode

`Super + r` disables the `inactive-opacity` (from `picom`) for when readability is important.  An indicator is displayed via polybar.

*Disabled:*
![image](https://user-images.githubusercontent.com/81622310/212110520-c782704b-9780-47af-b3c3-46b231ee8805.png)

*Enabled:*
![image](https://user-images.githubusercontent.com/81622310/212110576-71a817aa-7785-4384-a817-30b3ee94e417.png)

# Key Bindings

A few notes on the bindings:

- Keys combined with the `Super` key are reserved for OS and WM related actions.  
- Arrows and `hjkl` keys are interchangeable.

### **i3**:

|  Binding  |  Action   |
| :-------: | :-------: |
| Super + d | App launcher |
| Super + p | Powermenu |
| Super + t | Alacritty |
| Super + n | Neovide |
| Super + b | BTop++ |
| Super + r | Toggle read mode |
| Super + tab | Windows |
| Super + Arrow | Cycle windows |
| Super + Shift + Arrow | Move window |
| Super + Number | Go to workspace |

# Theme

*TODO*

# Neovim

The [Neovim config](https://github.com/Alex-vZyl/.dotfiles/tree/main/.config/nvim) has a decent amount of work and is very close to a proper IDE.  Why didn't I use [LunarVim](https://github.com/LunarVim/LunarVim), [NvChad](https://github.com/NvChad/NvChad) or [SpaceVim](https://github.com/liuchengxu/space-vim)?  I like doing things myself. 

*Overview:*
![image](https://user-images.githubusercontent.com/81622310/210983899-cc5d3016-8dcb-46e3-a6ce-5d3b60431524.png)

*[Dashboard](https://github.com/nvim-telescope/telescope.nvim):*
![image](https://user-images.githubusercontent.com/81622310/210983209-abe76da1-a190-4d3d-be10-8f570595dd7f.png)

*[Telescope](https://github.com/nvim-telescope/telescope.nvim):*
![image](https://user-images.githubusercontent.com/81622310/210984138-f650324c-4a5a-4fb1-a5c1-e14b26ef40c9.png)




