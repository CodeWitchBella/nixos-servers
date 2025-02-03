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

    songbook = {
      url = "github:CodeWitchBella/songbook";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    deploy-rs.url = "github:serokell/deploy-rs";

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    quadlet-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    inputs@{
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
    }:
    let
      mkDeployPkgs =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
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
        modules = (import ./modules/module-list.nix) ++ [
          ./systems/data.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          disko.nixosModules.disko
          inputs.quadlet-nix.nixosModules.quadlet
          { networking.hostName = "data"; }
        ];
      };
      nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = (import ./modules/module-list.nix) ++ [
          ./systems/vps.nix
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          inputs.authentik-nix.nixosModules.default
          inputs.vpsadminos.nixosConfigurations.container
          inputs.simple-nixos-mailserver.nixosModule
          inputs.quadlet-nix.nixosModules.quadlet
          { networking.hostName = "vps"; }
        ];
      };
      nixosConfigurations.hetzner = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = (import ./modules/module-list.nix) ++ [
          ./systems/hetzner.nix
          impermanence.nixosModules.impermanence
          disko.nixosModules.disko
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          inputs.quadlet-nix.nixosModules.quadlet
          { networking.hostName = "hetzner"; }
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
      deploy.nodes.vps = {
        hostname = "vps.isbl.cz";
        profiles.system = {
          user = "root";
          path = deployPkgsX86.deploy-rs.lib.activate.nixos self.nixosConfigurations.vps;
        };
      };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlays.default ];
        };
        deploy = "${pkgs.deploy-rs}/bin/deploy";
      in
      {
        formatter = pkgs.nixfmt-rfc-style;
        devShell = pkgs.devshell.mkShell {
          packages = [
            agenix.packages."${system}".default
            pkgs.deploy-rs
            pkgs.jq
          ];
          commands = [
            {
              name = "deploy:data";
              command = "${deploy} '.#data'";
            }
            {
              name = "deploy:vps";
              command = "${deploy} '.#vps'";
            }
            {
              name = "deploy:hetzner";
              command = "${deploy} '.#hetzner'";
            }
            {
              name = "deploy-remotebuild:vps";
              command = "${deploy} '.#vps' --remote-build";
            }
            {
              name = "deploy-remotebuild:data";
              command = "${deploy} '.#data' --remote-build";
            }
            {
              name = "deploy-remotebuild:hetzner";
              command = "${deploy} '.#hetzner' --remote-build";
            }
          ];
        };
      }
    ));
}
