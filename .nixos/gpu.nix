{ config, ... }:

{
  services.xserver.videoDrivers = ["nvidia"];
  # TODO: Why does this break?
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

  hardware.graphics.enable = true;
}
