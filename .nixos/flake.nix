{
  description = "Nixos config flake";

  inputs = {
    # Neovim 0.10.0
    neovim.url = "github:neovim/neovim?dir=contrib&rev=27fb62988e922c2739035f477f93cc052a4fee1e";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        /etc/nixos/configuration.nix

        # Custom configs.
        ./system.nix
        ./network.nix
        ./gpu.nix
        ./cpu.nix
        ./services.nix
        ./dev.nix
        ./user.nix
      ];
    };
  };
}
