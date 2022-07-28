# DotFiles

The dotfiles for my personal setup.  Currently only supports Arch based distros using Gnome.  I plan on expanding the install scripts and supporting more platforms so that I can easily direct new people that wants to use Linux to this repo.  There will be basic installers (just browser, office tools, etc.), development installers (github, neovide, vscode, etc.) and then the full installer that I use personally.

## Installation

To install everything, simply copy and paste this into the terminal.

```bash
git clone https://github.com/Alex-vZyl/DotFiles
cd DotFiles
sudo chmod +x install.sh
./install.sh
```

If you want to configure the terminal, open `alacritty` and run

```fish
tide configure
```

and follow the steps.

## Screenshots

![image](https://user-images.githubusercontent.com/81622310/181455188-7a945390-8758-4bcf-8d50-ebf0683b19f6.png)
*Desktop with gnome extensions.*

![image](https://user-images.githubusercontent.com/81622310/181454707-cb86d1ae-7eef-4793-8a4f-6f6e17c0e2d5.png)
*[Alacritty](https://github.com/alacritty/alacritty) with [fish](https://github.com/fish-shell/fish-shell) and [tide](https://github.com/IlanCosman/tide).*

![image](https://user-images.githubusercontent.com/81622310/181458526-bda18060-eaa5-4119-a90f-eb8f80d81431.png)
*Default gnome overview with [nice icons](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) and blur effect.*

![image](https://user-images.githubusercontent.com/81622310/179122222-5815861b-6082-4fa6-b9be-4c14da944f65.png)
*Adds my [neovim](https://github.com/neovim/neovim) [setup](https://github.com/Alex-vZyl/NeovimConfig).  Also installs [neovide](https://github.com/neovide/neovide), so use that!*
