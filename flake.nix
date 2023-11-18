{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager }: {
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
  };
}
