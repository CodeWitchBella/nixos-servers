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

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    authentik-nix = {
      url = "github:mayflower/authentik-nix";
    };
    vpsadminos.url = "github:vpsfreecz/vpsadminos";
  };
  outputs = inputs@{ self, nixpkgs, home-manager, flake-utils, agenix, devshell, disko, ... }: {
    nixosConfigurations.data = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./systems/data.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        inputs.authentik-nix.nixosModules.default
        disko.nixosModules.disko
        { networking.hostName = "data"; }
      ];
    };
    nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./systems/vps.nix
        agenix.nixosModules.default
        home-manager.nixosModules.home-manager
        inputs.vpsadminos.nixosConfigurations.container
        { networking.hostName = "vps"; }
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
            name = "deploy:data";
            command = "nixos-rebuild switch --flake .#data --target-host root@data.isbl.cz";
          }
          {
            name = "deploy:vps";
            command = "nixos-rebuild switch --flake .#vps --target-host root@vps.isbl.cz --use-substitutes";
          }
          {
            name = "deploy-remotebuild:data";
            command = "deploy --build-host root@data.isbl.cz";
          }
        ];
      };
    }
  ));
}
