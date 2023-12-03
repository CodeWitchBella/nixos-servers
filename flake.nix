{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
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
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    agenix,
    devshell,
    disko,
    ...
  }:
    {
      nixosConfigurations.data = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ./systems/data.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          inputs.authentik-nix.nixosModules.default
          disko.nixosModules.disko
          {networking.hostName = "data";}
        ];
      };
      nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./systems/vps.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          inputs.vpsadminos.nixosConfigurations.container
          {networking.hostName = "vps";}
        ];
      };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [devshell.overlays.default];
        };
      in {
        formatter = inputs.alejandra.defaultPackage.${system};
        devShell = pkgs.devshell.mkShell {
          packages = [agenix.packages."${system}".default];
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
              name = "deploy-remotebuild:vps";
              command = "nixos-rebuild switch --flake .#vps --target-host root@vps.isbl.cz --build-host root@vps.isbl.cz --fast";
            }
            {
              name = "deploy-remotebuild:data";
              command = "nixos-rebuild switch --flake .#data --target-host root@data.isbl.cz --build-host root@data.isbl.cz --fast";
            }
          ];
        };
      }
    ));
}
