# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024;  # Mb
  } ];

  # Nvidia.
  services.xserver.videoDrivers = ["intel" "nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Experimental.
    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };

  nix.settings.experimental-features = ["nix-command"];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  time.timeZone = "Africa/Johannesburg";
  i18n.defaultLocale = "en_ZA.UTF-8";

  # Setup GUI environment.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.sddm.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "za";
    xkb.options = "caps:escape";
    autoRepeatDelay = 165;
    autoRepeatInterval = 50;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Touchpad support.
  services.xserver.libinput.enable = true;

  environment.systemPackages = with pkgs; [
      vim
    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    description = "Alexander van Zyl";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs;
    let
      polybar = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };
    in
    [
      polybar
      i3
      i3ipc-glib
      pulseaudio
      librewolf
      neovim
      git
      pass
      lshw
      flameshot
      libgcc
      dunst
      ripgrep
      trash-cli
      newsboat
      rofi
      rofi-pass
      pfetch
      lazygit
      fish
      tmux
      bat
      zoxide
      btop
      nvtop
      zathura
      ranger
      dunst
      feh
      nodejs
      gh
      arandr
      gnome.nautilus
      picom
      blueman
      betterlockscreen
      gcc
      unzip
      starship
      tree-sitter
      wezterm

      (python311.withPackages(ps: with ps; [pytz]))

      brave
      dua
      polkit
      polkit_gnome
      gnupg
      pinentry
    ];
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.gnupg.agent.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
    };
  };
}
