{ pkgs, ... }:

{
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Setup GUI environment.
  services.xserver.windowManager.i3.enable = true;
  services.displayManager.sddm.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb = {
        options = "caps:escape";
        layout = "za";
    };
    autoRepeatDelay = 165;
    autoRepeatInterval = 50;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  # Security.  Not sure if this will even help at all.
  services.clamav = {
    scanner.enable = true;
    daemon.enable = false;
    updater.enable = true;
  };

  # Needed for drives.
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}
