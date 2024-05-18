{ config, ... }:

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

  # If steam is enabled, this is not necessary.
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia.prime = {
    sync.enable = false;
    offload = {
        enable = false;
        enableOffloadCmd = false;
    };

    # NOTE: These values are different on each system.
    # Integrated.
    intelBusId = "PCI:0:2:0";
    # Dedicated.
    nvidiaBusId = "PCI:1:0:0";
  };
}
