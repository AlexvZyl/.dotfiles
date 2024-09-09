{ pkgs, inputs, ... }:

{
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024;  # Mb
  } ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_ZA.UTF-8";

  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;

  # TODO: Sort this out
  environment.systemPackages = [
    pkgs.openvpn
    pkgs.fzf
    pkgs.vim
    pkgs.parallel
    pkgs.glibc
    pkgs.zip
    pkgs.libGL
    pkgs.pciutils
    pkgs.openfortivpn
    pkgs.xorg.xev
    pkgs.p7zip
    pkgs.dunst
    pkgs.xclip
    pkgs.xorg.xmodmap
    pkgs.eza
    pkgs.gnumake
    pkgs.zellij
    pkgs.libz
    pkgs.cron
    pkgs.file
    pkgs.pinentry
    pkgs.fd
    pkgs.pamixer
    pkgs.gnupg
    pkgs.polkit
    pkgs.polkit_gnome
    pkgs.gcc
    pkgs.unzip
    pkgs.git
    pkgs.luajitPackages.luarocks-nix
    pkgs.pass
    pkgs.go
    pkgs.julia
    pkgs.zulu
    pkgs.luarocks
    pkgs.zip
    pkgs.lshw
    pkgs.libgcc
    pkgs.pulseaudio
    pkgs.blueman
    pkgs.betterlockscreen
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.polybar
    pkgs.i3
    pkgs.ffmpeg
    pkgs.i3ipc-glib
    pkgs.tmux
    pkgs.nodejs
    pkgs.fish
    pkgs.bat
    pkgs.trash-cli
    pkgs.ripgrep
    pkgs.btop
    pkgs.nvtopPackages.full
    pkgs.efibootmgr
    pkgs.rustup
    pkgs.refind
    pkgs.libpqxx
    pkgs.postgresql.lib
    pkgs.postgresql
    pkgs.wget
    pkgs.libxkbcommon
    pkgs.libnotify
    pkgs.dmidecode
    pkgs.nmap
    pkgs.ethtool
    pkgs.iperf
    pkgs.iperf2
    pkgs.bc

    inputs.picom.packages.${pkgs.system}.default
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      # Enable support for polybar.
      polybar = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };
    };
  };

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  # Just install jetbrains from nerdfonts.
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
