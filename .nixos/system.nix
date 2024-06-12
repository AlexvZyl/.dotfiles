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

  environment.systemPackages = with pkgs; [
    openvpn
    fzf
    vim
    parallel
    glibc
    zip
    libGL
    pciutils
    openfortivpn
    xorg.xev
    p7zip
    dunst
    xclip
    xorg.xmodmap
    eza
    gnumake
    zellij
    libz
    cron
    file
    picom
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
    blueman
    betterlockscreen
    python311
    python311Packages.pip
    polybar
    i3
    ffmpeg
    i3ipc-glib
    tmux
    nodejs
    fish
    bat
    trash-cli
    ripgrep
    btop
    nvtopPackages.full
    efibootmgr
    rustup
    refind
    libpqxx
    postgresql.lib
    postgresql
    wget
    libxkbcommon
    libnotify
    dmidecode
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

  programs.neovim = {
    enable = true;
    package = inputs.neovim.defaultPackage.x86_64-linux;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
