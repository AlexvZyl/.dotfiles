# .dotfiles

![image](https://user-images.githubusercontent.com/81622310/233985068-9a630612-5d32-4cc0-a2e1-978d5a94856a.png)

[![Scripts](https://github.com/AlexvZyl/.dotfiles/workflows/ShellCheck/badge.svg)](https://github.com/AlexvZyl/.dotfiles/actions?workflow=ShellCheck) 

The configuration files for my Linux desktop.  Supports Arch based distros using Gnome and/or i3.  Also, currently it assumes you have an Nvidia GPU and Intel CPU.

I mainly use i3, but I also install Gnome for when people do not want to mess around with a tiling WM.  All of the screenshots are for i3 and the gnome configs are very basic.  

> ℹ️ &nbsp; Remember to choose i3 at the login screen.

> ⚠️ &nbsp; These are my personal dotfiles, which means they will continuously change.

# Installation

To install everything, simply copy and paste this into the terminal.

> ℹ️ &nbsp; This script assumes that you have a working Arch installation.

> ⚠️ &nbsp; I still need to properly test this.

```bash
curl https://github.com/AlexvZyl/.dotfiles/tree/main/.scripts/install/setup.sh | bash
reboot
```

# Theme

The theme is based on my Neovim plugin, [nordic.nvim](https://github.com/AlexvZyl/nordic.nvim).  It is a warmer and darker version of the [Nord](https://www.nordtheme.com/) color palette.

# Showcase

Some screenshots showing off the desktop and rice, as well as some custom features I wrote.  Everything has to be *just right*.  I am spending 8+ hours a day on this working, so it might as well be a nice experience.

> ⚠️ &nbsp; Some of these are outdated, I will update them at a later stage.

<details>

<summary>Overview</summary>

</br>

Wallpapers can be found at [this ImageGoNord repo](https://github.com/linuxdotexe/nordic-wallpapers) (they "norded" some nice wallpapers) and [locally](https://github.com/AlexvZyl/.dotfiles/tree/main/.wallpapers).

*For Reddit:*

![image](https://user-images.githubusercontent.com/81622310/212382904-0502af7d-653a-4834-8663-c449cfbcfb3c.png)

![image](https://user-images.githubusercontent.com/81622310/212382132-597b93e8-04b3-4497-93ce-8264bdc02fc0.png)

![image](https://user-images.githubusercontent.com/81622310/212382290-a923c5be-9d16-4e44-8fc0-090b05865316.png)

*Notifications via [dunst](https://github.com/dunst-project/dunst):*
![image](https://user-images.githubusercontent.com/81622310/210980911-cb7825d5-1ac2-4db9-b34a-f92887701d1d.png)

*Launcher via [rofi](https://github.com/adi1090x/rofi):*
![image](https://user-images.githubusercontent.com/81622310/211895894-663f3480-d2d9-4546-8f1b-04217cb2dd75.png)

*Powermenu via [rofi](https://github.com/adi1090x/rofi):*
![image](https://user-images.githubusercontent.com/81622310/211911407-050741e9-d7d7-412c-ac12-044f002e8b6f.png)

*Lock screen via [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen):*
![image](https://user-images.githubusercontent.com/81622310/211187368-5d8e1215-4482-4506-9cd9-6508d980f1f3.png)

</details>

# Key Bindings

A few notes on the bindings:

- Keys combined with the `Super` key are reserved for OS and WM related actions.  
- Arrows and `hjkl` keys are interchangeable.

<details>

<summary>Bindings table</summary>

</br>

|  Binding  |  Action   |
| :-------: | :-------: |
| Super + d | App launcher |
| Super + p | Powermenu |
| Super + t | Terminal |
| Super + n | Neovim |
| Super + b | BTop++ |
| Super + g | NVtop |
| Super + R | Toggle read mode |
| Super + tab | Windows |
| Super + Arrow | Cycle windows |
| Super + Shift + Arrow | Move window |
| Super + Number | Go to workspace |
| Super + r | Newsboat |
| Super + w | iwctl |

</details>

# Neovim Config

This [config](https://github.com/AlexvZyl/.dotfiles/tree/main/.config/nvim) has a decent amount of work and is basically a fully fledged IDE.  Why didn't I use [LunarVim](https://github.com/LunarVim/LunarVim), [NvChad](https://github.com/NvChad/NvChad) or [SpaceVim](https://github.com/liuchengxu/space-vim)?  I like doing things myself.

> ℹ️ &nbsp; I try to keep all of the key bindings in [this file](https://github.com/AlexvZyl/.dotfiles/blob/main/.config/nvim/lua/alex/key-bindings.lua).

## Installation

If you wish to only use the Neovim configs, you can install them with:

```bash
curl https://github.com/AlexvZyl/.dotfiles/tree/main/.scripts/install/neovim.sh | bash

```
And to update:
```bash
alias nvim-git="git --work-tree=\"$HOME/\" --git-dir=\"$HOME/.config/nvim/.git/\""
nvim-git fetch && nvim-git pull
```

![image](https://user-images.githubusercontent.com/81622310/233982609-f9c15e39-da60-43d8-8c5c-4761db95ad9d.png)
