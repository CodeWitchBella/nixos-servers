{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-data-kernel.url = "github:NixOS/nixpkgs?rev=9357f4f23713673f310988025d9dc261c20e70c6";
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

    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    quadlet-nix.inputs.nixpkgs.follows = "nixpkgs";

    flake-root.url = "github:srid/flake-root";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    make-shell.url = "github:nicknovitski/make-shell";
    deploy-rs.url = "github:serokell/deploy-rs";
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      agenix,
      deploy-rs,
      ...
    }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (top@{ config, withSystem, moduleWithSystem, ... }: {
      imports = [
        inputs.make-shell.flakeModules.default
        inputs.flake-root.flakeModule
      ];
      flake = {
        nixosConfigurations.hetzner = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = (import ./modules/module-list.nix) ++ [
            ./systems/hetzner.nix
            inputs.impermanence.nixosModules.impermanence
            inputs.disko.nixosModules.disko
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            inputs.quadlet-nix.nixosModules.quadlet
            { networking.hostName = "hetzner"; }
          ];
        };

        deploy.nodes.hetzner = {
          hostname = "hetzner.isbl.cz";
          profiles.system = {
            user = "root";
            path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.hetzner;
          };
        };
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem = { config, pkgs, ... }: {
        imports = [
          ./podman/generator.nix
        ];
        make-shells.default = {
          packages = [
            pkgs.just
            pkgs.deploy-rs
            pkgs.ragenix
          ];
        };
      };
    });
}
