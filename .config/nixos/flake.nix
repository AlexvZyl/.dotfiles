{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    neovim.url = "github:neovim/neovim?dir=contrib&rev=27fb62988e922c2739035f477f93cc052a4fee1e";
  };

  outputs = { self, nixpkgs, neovim, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
      ];
    };
  };
}
