{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
		yazi.url = "github:sxyazi/yazi";

    # While we wait...
    zen-browser.url = "github:MarceColl/zen-browser-flake";
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
        ./root.nix
        ./network.nix
        ./gpu.nix
        ./cpu.nix
        ./services.nix
        ./alex.nix
      ];
    };
  };
}
