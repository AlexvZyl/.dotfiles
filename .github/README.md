# 🗃️ .dotfiles

<div align="center">
  
```markdown
👋 Welcome to my personal dotfiles!
Continuous change is to be expected...
```
  
![image](https://github.com/AlexvZyl/.dotfiles/assets/81622310/55c6780d-00c6-451e-9066-0a2365c4d7a9)

[![ShellCheck](https://github.com/AlexvZyl/.dotfiles/workflows/ShellCheck/badge.svg)](https://github.com/AlexvZyl/.dotfiles/actions?workflow=ShellCheck) 
[![StyLua](https://github.com/AlexvZyl/.dotfiles/workflows/StyLua/badge.svg)](https://github.com/AlexvZyl/.dotfiles/actions?workflow=StyLua) 
![Size](https://img.shields.io/github/repo-size/AlexvZyl/.dotfiles?style=flat)

</div>

The configuration files for my Linux desktop.  Supports Arch based distros using Gnome and/or i3.  Also, currently it assumes you have an Nvidia GPU and Intel CPU.  I mainly use i3, but I also install Gnome for when people do not want to mess around with a tiling WM.  All of the screenshots are for i3 and the gnome configs are very basic.  

# Full Installation

To install everything, simply copy and paste this into the terminal.

> ℹ️ &nbsp; This script assumes that you have a working Arch installation.  Remember to choose i3 at the login screen.

> ⚠️ &nbsp; I still need to properly test this.

```bash
curl -s https://raw.githubusercontent.com/AlexvZyl/.dotfiles/main/.scripts/install/bootstrap.sh > ~/bootstrap.sh
chmod +x ~/bootstrap.sh && ~/bootstrap.sh && rm ~/bootstrap.sh
reboot
```

# Minimal Installation

Sometimes I just want to get work done on a Linux machine.  A minimal installation can be done with:

```bash
curl -s https://raw.githubusercontent.com/AlexvZyl/.dotfiles/main/.scripts/install/minimal_workspace.sh > ~/bootstrap.sh
chmod +x ~/bootstrap.sh && ~/bootstrap.sh && rm ~/bootstrap.sh
```
And to update:
```bash
workspace-git fetch
workspace-git pull
```

<details>

<summary>⚙️ Components</summary>

</br>

- Neovim
- Kitty
- Tmux
- Fonts
- Fish
- Scripts
- exa
- bat

</details>

# Privacy and Security

Although I like making it look as nice as possible, these dotfiles also try to be private and secure.  This is a journey, not a destination, and I am open to any input.

<details>

<summary>🛡️ Measures</summary>

</br>

- [Scripts](https://github.com/AlexvZyl/.dotfiles/tree/main/.scripts/security) I sometimes use.
- Manually keeping system up to date (`yay -Syyu`)
- Malware scanning and database updating ([clamav](https://github.com/Cisco-Talos/clamav))
- Firewall ([ufw](https://wiki.archlinux.org/title/Uncomplicated_Firewall))
- Ban IPs ([fail2ban](https://github.com/fail2ban/fail2ban))
- Using [Signal](https://github.com/signalapp) (when possible)
- Hosting API keys in a private repo
- Hardened firefox ([user.js](https://github.com/arkenfox/user.js/))
- I could install the hardened Linux kernel, but that might be slightly pedantic...
- Port scanning ([nmap](https://github.com/nmap/nmap), [rustscan](https://github.com/RustScan/RustScan))

</details>

# Theme

Personally, I want a balance between good looking colors that stand out, and soft colors that will not destroy my eyes.

The theme is based on my Neovim plugin, [nordic.nvim](https://github.com/AlexvZyl/nordic.nvim).  It is a warmer and darker version of the [Nord](https://www.nordtheme.com/) color palette.  Wallpapers can be found at [this ImageGoNord repo](https://github.com/linuxdotexe/nordic-wallpapers) (they "norded" some nice wallpapers) and [locally](https://github.com/AlexvZyl/.dotfiles/tree/main/.wallpapers).

# Showcase

Some screenshots showing off the desktop and rice, as well as some custom features I wrote.  Everything has to be *just right*.  I am spending 8+ hours a day on this working, so it might as well be a nice experience.

<details>

<summary>📷 Preview</summary>

</br>

*Launcher via [rofi](https://github.com/adi1090x/rofi):*
![image](https://github.com/AlexvZyl/.dotfiles/assets/81622310/550f9794-0531-4f27-9433-ea76ceb381d7)

*Lock screen via [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen):*  
![image](https://github.com/AlexvZyl/.dotfiles/assets/81622310/4eeeab12-e778-4f6b-aa19-4f6e0cbe9767)

</details>

# Key Bindings

A few notes on the bindings:

- Keys combined with the `Super` key are reserved for OS and WM related actions.  
- Arrows and `hjkl` keys are interchangeable.

<details>

<summary>⌨️ Bindings table</summary>

</br>

|  Binding  |  Action   |
| :-------: | :-------: |
| Super + d | App launcher |
| Super + s | Tmux sessions |
| Super + p | Powermenu |
| Super + t | Terminal |
| Super + T | Tor terminal session |
| Super + n | Neovim |
| Super + m | Resource monitor (BTop++) |
| Super + g | GPU monitor (NVtop) |
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

> ℹ️ &nbsp; I try to keep all of the key bindings in [one file](https://github.com/AlexvZyl/.dotfiles/blob/main/.config/nvim/lua/alex/keymaps/init.lua).  So if you want to use the configs, this is the only file you have to familiarise yourself with.  You can add more LSPs to the end of [this file](https://github.com/AlexvZyl/.dotfiles/blob/main/.config/nvim/lua/alex/lang/lsp/clients.lua).

<details>

<summary>📷 Preview</summary>
  
</br>

![image](https://github.com/AlexvZyl/.dotfiles/assets/81622310/4032df89-74da-4152-b606-8d608d828de3)

![image](https://github.com/AlexvZyl/.dotfiles/assets/81622310/c0a1c04d-5665-4402-98f2-e5a92f7c12c1)
  
</details>

---

<div align="center">
  
*These dotfiles were briefly featured in a [TechHut Video](https://youtu.be/7NLtw26qJtU?t=789).*
  
</div>
