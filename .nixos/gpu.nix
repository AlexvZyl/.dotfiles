{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = ["nvidia"];
  # TODO: Why does this break?
  # services.xserver.videoDrivers = ["nvidia" "intel"];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;

    nvidiaSettings = true;
    forceFullCompositionPipeline = true;

    # NOTE: This build failed at some point.  Not sure if it will be fixed later.
    package = config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs (oldAttrs: {
      buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.libtirpc ];
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.pkg-config ];
    });

    powerManagement.enable = true;
    nvidiaPersistenced = true;
  };

  hardware.graphics.enable = true;
}
