{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";

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

    authentik-nix.url = "github:nix-community/authentik-nix";
    vpsadminos.url = "github:vpsfreecz/vpsadminos";
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix = {
      url = "git+https://git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    songbook = {
      url = "github:CodeWitchBella/songbook";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    agenix,
    devshell,
    disko,
    impermanence,
    deploy-rs,
    ...
  }: let
    mkDeployPkgs = system: let
      pkgs = import nixpkgs {inherit system;};
      # nixpkgs with deploy-rs overlay but force the nixpkgs package
      deployPkgs = import nixpkgs {
        inherit system;
        overlays = [
          deploy-rs.overlay # or deploy-rs.overlays.default
          (self: super: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              lib = super.deploy-rs.lib;
            };
          })
        ];
      };
    in
      deployPkgs;
    deployPkgsAarch = mkDeployPkgs "aarch64-linux";
    deployPkgsX86 = mkDeployPkgs "x86_64-linux";
  in
    {
      nixosConfigurations.data = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules =
          (import ./modules/module-list.nix)
          ++ [
            ./systems/data.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            inputs.lix-module.nixosModules.default
            {networking.hostName = "data";}
          ];
      };
      nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules =
          (import ./modules/module-list.nix)
          ++ [
            ./systems/vps.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            inputs.authentik-nix.nixosModules.default
            inputs.vpsadminos.nixosConfigurations.container
            inputs.simple-nixos-mailserver.nixosModule
            inputs.lix-module.nixosModules.default
            {networking.hostName = "vps";}
          ];
      };
      nixosConfigurations.hetzner = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules =
          (import ./modules/module-list.nix)
          ++ [
            ./systems/hetzner.nix
            impermanence.nixosModules.impermanence
            disko.nixosModules.disko
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            inputs.lix-module.nixosModules.default
            {networking.hostName = "hetzner";}
          ];
      };

      # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      deploy.nodes.data = {
        hostname = "data.isbl.cz";
        profiles.system = {
          user = "root";
          path = deployPkgsAarch.deploy-rs.lib.activate.nixos self.nixosConfigurations.data;
        };
      };

      deploy.nodes.hetzner = {
        hostname = "hetzner.isbl.cz";
        profiles.system = {
          user = "root";
          path = deployPkgsX86.deploy-rs.lib.activate.nixos self.nixosConfigurations.hetzner;
        };
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
          packages = [
            agenix.packages."${system}".default
            pkgs.deploy-rs
          ];
          commands = [
            {
              name = "deploy:data";
              command = "deploy '.#data'";
            }
            {
              name = "deploy:vps";
              command = "nixos-rebuild switch --flake .#vps --target-host vps.isbl.cz --use-remote-sudo --use-substitutes";
            }
            {
              name = "deploy:hetzner";
              command = "nixos-rebuild switch --flake .#hetzner --target-host hetzner.isbl.cz --use-remote-sudo --use-substitutes";
            }
            {
              name = "deploy-remotebuild:vps";
              command = "nixos-rebuild switch --flake .#vps --target-host vps.isbl.cz --build-host vps.isbl.cz --use-remote-sudo --fast";
            }
            {
              name = "deploy-remotebuild:data";
              command = "deploy '.#data' --remote-build";
            }
            {
              name = "deploy-remotebuild:hetzner";
              command = "nixos-rebuild switch --flake .#hetzner --target-host hetzner.isbl.cz --build-host hetzner.isbl.cz --use-remote-sudo --fast";
            }
          ];
        };
      }
    ));
}
