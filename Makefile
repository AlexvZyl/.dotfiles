PREFIX ?= /usr
.ONESHELL:

all:
	@printf "Run make install to install AlexvZyl's dotfiles.\n"
install:
	@printf "\e[0;34m>>\e[0m AlexvZyl's dotfiles / Makefile v1.0.0\n"
	@printf "\e[0;34m>>\e[0m Made by o69mar"
	@printf "\n\n"
	@read -p ">> This Makefile only works on arch (btw), If you are using arch. press ENTER to install AlexvZyl's dotfiles.."
	@printf "\e[0;34m>>\e[0m Making sure all packages are up to date..\n"
	@sudo pacman -Syu
	@printf "\e[0;34m>>\e[0m Installing git and base-devel..\n"
	@sudo pacman -S --noconfirm git base-devel
	@printf "\e[0;34m>>\e[0m Installing yay..\n"
	@git clone https://aur.archlinux.org/yay.git ~/GitHub/yay/
	@cd ~/GitHub/yay/ && makepkg -si && cd ~
	@printf "\e[0;34m>>\e[0m Installing pamac and polkit-gnome..\n"
	@yay -S libpamac-aur pamac-aur # Only AUR.
	@sudo pacman -Syu --noconfirm polkit-gnome
	@/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
	@printf "\e[0;34m>>\e[0m Enabling AUR on pamac..\n"
	@sudo sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf
	@printf "\e[0;34m>>\e[0m Will from now on use pamac..\n"
	@printf "\e[0;34m>>\e[0m Installing firefox and brave..\n"
	@sudo pamac install firefox brave-bin --no-confirm
	@printf "\e[0;34m>>\e[0m Installing office stuff..\n"
	@sudo pamac install onlyoffice-bin xournalpp --no-confirm
	@orintf "\e[0;34m>>\e[0m Installing fonts..\n"
	@sudo pamac install nerd-fonts-jetbrains-mono --no-confirm
	@printf "\e[0;34m>>\e[0m Installing manuals..\n"
	@sudo pamac install man-db --no-confirm
	@printf "\e[0;34m>>\e[0m Installing utils..\n"
	@sudo pamac install scrot zathura zathura-pdf-mupdf-git cpu-x fuse-common powertop speedtest-cli gnome-calculator balena-etcher btop nvtop thunar lazygit flameshot brightnessctl pfetch bottom dunst --no-confirm
	@printf "\e[0;34m>>\e[0m Installing papirus icon theme..\n"
	@sudo pamac install papirus-icon-theme --no-confirm
	@printf "\e[0;34m>>\e[0m Installing lxappearance, gtk themes..\n"
	@sudo pamac install lxappearance-gtk3 gruvbox-material-gtk-theme-git gtk-theme-material-black --no-confirm
	@printf "\e[0;34m>>\e[0m Installing bootloader.. (refind)"
	@sudo pamac install refind --no-confirm
	@refind-install
	@sudo chmod +x ~/.scripts/setup_refind.sh && ~/.scripts/setup_refind.sh
	@printf "\e[0;34m>>\e[0m Installing LY login manager..\n"
	@sudo pamac install ly --no-confirm
	@printf "\e[0;34m>>\e[0m Installing sddm..\n"
	@sudo pamac install sddm sddm-sugar-dark sddm-sugar-candy-git archlinux-tweak-tool-git --no-confirm
	@sudo systemctl disable display-manager && sudo systemctl enable sddm
	@sudo touch /etc/sddm.conf
	@sudo sh -c "echo '[Theme]' >> /etc/sddm.conf"
	@sudo sh -c "echo 'Current=sugar-candy' >> /etc/sddm.conf"
	@sudo cp ~/.wallpapers/mountain_jaws.jpg /usr/share/sddm/themes/sugar-candy/
	@sudo mv /usr/share/sddm/themes/sugar-candy/mountain_jaws.jpg /usr/share/sddm/themes/sugar-candy/wall_secondary.png
	@printf "\e[0;34m>>\e[0m Installing gnome stuff..\n"
	@sudo pamac install gnome-browser-connector gnome-tweaks --no-confirm
	@printf "\e[0;34m>>\e[0m Installing bluetooth stuff..\n"
	@sudo pamac install blueman --no-confirm 
	@systemctl enable bluetooth.service && systemctl restart bluetooth.service
	@sudo sed -i 's/#AutoEnable=false/AutoEnable=true/g' /etc/bluetooth/main.conf
	@printf "\e[0;34m>>\e[0m Installing terminal and coding stuff (including github, neovim, nodejs etc)..\n"
	@sudo pamac install alacritty --no-confirm
	@sudo pamac install neovim ripgrep neovide xclip nvim-packer-git --no-confirm
	@sudo pamac install nodejs github-desktop github-cli code --no-confirm
	@printf "\e[0;34m>>\e[0m Installing communication stuff (e.g discord signal thunderbird)..\n"
	@sudo pamac install thunderbird whatsapp-nativefier discord signal-desktop --no-confirm
	@printf "\e[0;34m>>\e[0m Installing i3 and polybar stuff..\n"
	@sudo pamac install feh xborder-git cronie rofi rofi-greenclip picom --no-confirm
	@chmod +x ~/.config/picom/scripts/toggle-picom-inactive-opacity.sh.
	@chmod +x ~/.config/polybar.personal/scripts/check-read-mode-status.sh
	@sudo pamac install polybar python-pywal pywal-git networkmanager-dmenu-git calc --no-confirm
	@printf "\e[0;34m>>\e[0m Installing sound stuff..\n".
	@sudo pamac install pulseaudio pavucontrol alsa-utils --no-confirm
	@sudo sed -i 's/load-module module-udev-detect/load-module module-udev-detect tsched=0/g' /etc/pulse/default.pa
	@printf "\e[0;34m>>\e[0m Installing media, power mangement, programming stuff and enabling services..\n"
	@sudo pamac install playerctl --no-confirm
	@sudo pamac install tlp --no-confirm
	@systemctl enable tlp.service
	@systemctl mask systemd-rfkill.service
	@systemctl mask systemd-rfkill.socket
	@sudo tlp start
	@sudo pamac install julia-bin emf-langserver cmake python --no-confirm
	@printf "\e[0;34m>>\e[0m Enabling sysrq keys, install st-tui and set to run as admin, Add bnaries to sudoers, setup github app, install lang servers and betterlockscreen..\n"
	@sudo touch /etc/sysctl.d/99-sysctl.conf
	@sudo sh -c "echo 'kernel.sysrq=1' >> /etc/sysctl.d/99-sysctl.conf".
	@sudo pamac install s-tui --no-confirm
	@sudo sh -c "echo 'alex ALL = NOPASSWD: /usr/bin/s-tui, /usr/bin/pacman' > /etc/sudoers"
	@sudo chmod +x ~/.scripts/setup_git.sh && sudo ~/.scripts/setup_git.sh
	@sudo chmod +x ~/.config/nvim/lua/alex/lang/lsp/install-servers.sh
	@~/.config/nvim/lua/alex/lang/lsp/install-servers.sh
	@sudo pamac install betterlockscreen-git --no-confirm
	@betterlockscreen -u ~/.wallpapers/mountain_jaws.jpg --blur 0.5
	@betterlockscreen -u ~/.wallpapers/mountain_jaws.jpg
	@printf "\e[0;34m>>\e[0m Setting up fish..\n"
	@fish <<'END_FISH'
	curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
	fisher install IlanCosman/tide@v5t
	    echo "3\
          	  2\
          	  2\
          	  4\
          	  4\
                  5\
          	  2\
          	  1\
          	  1\
          	  2\
          	  2\
          	  y\
         " | tide configure
	END_FISH
	@clear
	@printf "\e[0;34m>>\e[0m AlexvZyl's dotfiles are now installed, you now need to reboot your system. Enjoy :)\n"

	
