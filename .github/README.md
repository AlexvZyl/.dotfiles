# .dotfiles

The configuration files for my Linux desktop.  Supports Arch based distros using Gnome and/or i3.

## Installation

To install everything, simply copy and paste this into the terminal.  Reboot after it is done.

```bash
sudo pacman -S git
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
mkdir ~/.dotfiles
config clone --bare https://github.com/Alex-vZyl/.dotfiles ~/.dotfiles/
config checkout -f
sudo chmod +x ~/.scripts/install.sh && ~/.scripts/install.sh
```

# Screenshots

I still have a lot of ricing that I want to do!

## Gnome

![image](https://user-images.githubusercontent.com/81622310/181455188-7a945390-8758-4bcf-8d50-ebf0683b19f6.png)
*Desktop with gnome extensions.*

![image](https://user-images.githubusercontent.com/81622310/181458526-bda18060-eaa5-4119-a90f-eb8f80d81431.png)
*Default gnome overview with [nice icons](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) and blur effect.*

## i3

![image](https://user-images.githubusercontent.com/81622310/182259303-18c68a39-02b4-420a-8522-95f8dfdb1624.png)
*[i3](https://github.com/i3/i3) split windows with [polybar](https://github.com/polybar/polybar).*

![image](https://user-images.githubusercontent.com/81622310/182259199-36a333a9-6775-4e9c-a353-ea1cf77a9f72.png)
*Just the desktop.*

## Terminal

![image](https://user-images.githubusercontent.com/81622310/182230693-461cca7f-572d-4010-b5c6-72dbeaa3690c.png)
*[Alacritty](https://github.com/alacritty/alacritty) with [fish](https://github.com/fish-shell/fish-shell) and [tide](https://github.com/IlanCosman/tide).*

## Neovim

![image](https://user-images.githubusercontent.com/81622310/182230490-e73244f4-bfb7-4612-bc03-36eec132bd01.png)
*Adds my [neovim](https://github.com/neovim/neovim) config.  Also installs [neovide](https://github.com/neovide/neovide), so use that!*
