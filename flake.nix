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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devshell.url = "github:numtide/devshell";
  };
  outputs = { self, nixpkgs, home-manager, flake-utils, agenix, devshell, ... }: {
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
  // (flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ devshell.overlays.default ];
      };
    in
    {
      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      devShell = pkgs.devshell.mkShell {
        packages = [ agenix.packages."${system}".default ];
        commands = [
          {
            name = "deploy";
            command = "nixos-rebuild switch --flake .#data --target-host isabella@data.isbl.cz --use-remote-sudo";
          }
          {
            name = "deploy-remotebuild";
            command = "deploy --build-host isabella@data.isbl.cz";
          }
        ];
      };
    }
  ));
}
