{ config, pkgs, ... }:

{
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
}
