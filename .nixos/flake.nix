{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    picom.url = "github:yshui/picom?rev=9bc657433ddbd2e2a630a6fb7d3264ce13b39a16"; # Picom 12-rc3
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      overlays = [
        inputs.neovim-nightly-overlay.overlays.default
      ];
    in
    {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = overlays; }

        # Pre-generated
        /etc/nixos/configuration.nix

        # System
        ./system.nix
        ./network.nix
        ./gpu.nix
        ./cpu.nix
        ./services.nix

        # User
        ./dev.nix
        ./user.nix
      ];
    };
  };
}
