{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { self, nixpkgs, home-manager, flake-utils, ... }: {
    nixosConfigurations.data = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          networking.hostName = "data";
          home-manager.users.isabella = import ./home.nix;
        }
      ];
    };
  }
  // (flake-utils.lib.eachDefaultSystem (system: { formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt; }));
}
