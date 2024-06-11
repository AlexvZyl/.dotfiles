{ config, ... }:

{
  services.xserver.videoDrivers = ["nvidia"];
  # services.xserver.videoDrivers = ["nvidia" "intel"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement.enable = true;
    nvidiaPersistenced = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
}
