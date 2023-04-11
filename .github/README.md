# .dotfiles

![image](https://user-images.githubusercontent.com/81622310/216946847-34a7169d-92ef-4f7f-8fed-f5deaa88bfc3.png)

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

<details>

<summary>Polybar</summary>

</br>

*TODO*

### References

- [Arcolinux](https://github.com/arcolinux/arcolinux-polybar/blob/master/etc/skel/.config/polybar/config)
- [Polybar-Themes](https://github.com/adi1090x/polybar-themes)

</details>

<details>

<summary>Read mode</summary>

</br>

`Super + r` disables the `inactive-opacity` (from `picom`) for when readability is important.  An indicator is displayed via polybar.

*Disabled:*
![image](https://user-images.githubusercontent.com/81622310/212110520-c782704b-9780-47af-b3c3-46b231ee8805.png)

*Enabled:*
![image](https://user-images.githubusercontent.com/81622310/212110576-71a817aa-7785-4384-a817-30b3ee94e417.png)

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
| Super + n | Neovide |
| Super + b | BTop++ |
| Super + r | Toggle read mode |
| Super + tab | Windows |
| Super + Arrow | Cycle windows |
| Super + Shift + Arrow | Move window |
| Super + Number | Go to workspace |

</details>

# Neovim Config

This [config](https://github.com/AlexvZyl/.dotfiles/tree/main/.config/nvim) has a decent amount of work and is basically a fully fledged IDE.  Why didn't I use [LunarVim](https://github.com/LunarVim/LunarVim), [NvChad](https://github.com/NvChad/NvChad) or [SpaceVim](https://github.com/liuchengxu/space-vim)?  I like doing things myself.

> ℹ️ &nbsp; I try to keep all of the key bindings in [this file](https://github.com/AlexvZyl/.dotfiles/blob/main/.config/nvim/lua/alex/key-bindings.lua).

![image](https://user-images.githubusercontent.com/81622310/219610304-549dcfe6-bc5c-4681-90b3-9992b8d7001a.png)
