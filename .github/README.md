# DotFiles

The dotfiles for my personal setup.  Currently only supports Arch based distros using Gnome and/or i3.  I plan on expanding the install scripts and supporting more platforms so that I can easily direct new people that wants to use Linux to this repo.  There will be basic installers (just browser, office tools, etc.), development installers (github, neovide, vscode, etc.) and then the full installer that I use personally.

## Installation

To install everything, simply copy and paste this into the terminal.

```bash
mkdir ~/.dotfiles
config clone --bare https://github.com/Alex-vZyl/DotFiles ~/.dotfiles/
config checkout
sudo chmod +x ~/.setup/install.sh
./~/.setup/install.sh
```

`config` is an alias that makes using the bare repo easier.  It is already added to `fish` and `bash`.

If you want to configure the terminal, open `alacritty` (or any `fish` instance) and run:

```fish
tide configure
```

# Screenshots

I still have a lot of ricing that I want to do!

## Gnome

![image](https://user-images.githubusercontent.com/81622310/181455188-7a945390-8758-4bcf-8d50-ebf0683b19f6.png)
*Desktop with gnome extensions.*

![image](https://user-images.githubusercontent.com/81622310/181458526-bda18060-eaa5-4119-a90f-eb8f80d81431.png)
*Default gnome overview with [nice icons](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) and blur effect.*

## i3

![image](https://user-images.githubusercontent.com/81622310/182231211-524bb73d-4db2-495c-bbdb-72b7ba86c813.png)
*[i3](https://github.com/i3/i3) split windows with [polybar](https://github.com/polybar/polybar).*

## Terminal

![image](https://user-images.githubusercontent.com/81622310/182230693-461cca7f-572d-4010-b5c6-72dbeaa3690c.png)
*[Alacritty](https://github.com/alacritty/alacritty) with [fish](https://github.com/fish-shell/fish-shell) and [tide](https://github.com/IlanCosman/tide).*

## Neovim

![image](https://user-images.githubusercontent.com/81622310/182230490-e73244f4-bfb7-4612-bc03-36eec132bd01.png)
*Adds my [neovim](https://github.com/neovim/neovim) config.  Also installs [neovide](https://github.com/neovide/neovide), so use that!*