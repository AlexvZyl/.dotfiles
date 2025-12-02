{ pkgs, ... }:

{
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Xserver.
  services = {
    xserver = {
      enable = true;
      # TODO: Don't think this works.
      xkb = {
          options = "caps:escape";
          layout = "za";
      };
      autoRepeatDelay = 165;
      autoRepeatInterval = 50;
    };
  };

  # Window manager.
  services.xserver.windowManager = {
    awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [ luarocks luadbi-mysql ];
    };
  };

  # Display managers.
  services.displayManager.ly = {
    enable = true;
    x11Support = true;
    settings = {
      # animation = "matrix";
      bigclock = true;
      hide_key_hints = true;
      clear_password = true;
      hide_version_string = true;
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.power-profiles-daemon.enable = false;

  # Touchpad support.
  services.libinput.enable = true;

  # Cron.
  services.cron = {
    enable = true;
    systemCronJobs = [
        "0 * * * * ~/.config/polybar/scripts/update_loadshedding.sh"
    ];
  };

  # Enable polkit.
  security.polkit.enable = true;
  programs.gnupg.agent.enable = true;
  # TODO: This might be messing with polkit.
  # systemd = {
  #   user.services.polkit-gnome-authentication-agent-1 = {
  #     description = "polkit-gnome-authentication-agent-1";
  #     wantedBy = [ "graphical-session.target" ];
  #     wants = [ "graphical-session.target" ];
  #     after = [ "graphical-session.target" ];
  #     serviceConfig = {
  #         Type = "simple";
  #         ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
  #         Restart = "on-failure";
  #         RestartSec = 1;
  #         TimeoutStopSec = 10;
  #       };
  #   };
  # };

  # Security.  Not sure if this will even help at all.
  services.clamav = {
    scanner.enable = false;
    daemon.enable = false;
    updater.enable = false;
  };

  # Needed for drives.
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
