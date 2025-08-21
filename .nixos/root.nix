{ pkgs, inputs, ... }:

{
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 32*1024;  # Mb
  } ];

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      # TODO: This does not seem to work.
      cores = 5;
      max-jobs = 2;
    };
  };

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_ZA.UTF-8";

  # Allow proprietary software.
  nixpkgs.config.allowUnfree = true;

  # TODO: Sort this out
  environment.systemPackages = [
    pkgs.nix-index
    pkgs.xorg.xhost

    pkgs.desktop-file-utils
    pkgs.testdisk

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
    pkgs.xsel
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
    pkgs.zulu
    pkgs.luarocks
    pkgs.zip
    pkgs.lshw
    pkgs.libgcc
    pkgs.pulseaudio
    pkgs.blueman
    pkgs.betterlockscreen
    pkgs.python3
    pkgs.python3Packages.pip
    pkgs.polybar
    pkgs.ffmpeg
    pkgs.tmux
    pkgs.nodejs
    pkgs.bat
    pkgs.trash-cli
    pkgs.btop
    pkgs.nvtopPackages.full
    pkgs.efibootmgr
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
    pkgs.findutils
    pkgs.openssl
    pkgs.findutils
    pkgs.linuxHeaders
    pkgs.ripgrep
    pkgs.linux-manual
    pkgs.man-pages
    pkgs.man-pages-posix
    pkgs.libGL
    pkgs.jq
    pkgs.xdotool
    pkgs.picom
    pkgs.trace-cmd
    pkgs.atuin
    inputs.zen-browser.packages."${pkgs.system}".default
  ];

  nixpkgs.config = {
    config.cudaSupport = true;
    packageOverrides = pkgs: {
      # Enable support for polybar.
      polybar = pkgs.polybar.override {
        pulseSupport = true;
      };
    };
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  # For non-NixOS binaries.
  # Currently used for:
  # - None
  # programs.nix-ld = {
  #   enable = false;
  #   libraries = with pkgs; [
  #   ];
  # };

  # Manpages.
  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
    man.generateCaches = false;
  };

  # Ftrace.
  boot.kernel.sysctl."kernel.ftrace_enabled" = true;
}
