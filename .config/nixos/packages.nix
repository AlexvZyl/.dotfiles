{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    parallel
    glibc
    zip
    openfortivpn
    p7zip
    cron
    file
    pinentry
    fd
    pamixer
    gnupg
    polkit
    openssh
    polkit_gnome
    gcc
    unzip
    git
    luajitPackages.luarocks-nix
    pass
    go
    julia
    zulu
    luarocks
    zip
    lshw
    libgcc
    pulseaudio
    picom
    blueman
    betterlockscreen
    python311
    python311Packages.pip
    polybar
    i3
    ffmpeg
    i3ipc-glib
    nodejs
    tmux
    fish
    bat
    trash-cli
    ripgrep
    btop
    nvtop
    efibootmgr
    rustup
    refind
    libpqxx
    postgresql.lib
    postgresql
    wget
  ];

  # Package overrides.
  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      polybar = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };
    };
  };

  programs.steam.enable = true;
  programs.neovim.enable = true;

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
