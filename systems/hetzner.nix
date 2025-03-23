{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    ../fake-modules/hetzner/hetzner.nix
    ../fake-modules/basics.nix
  ];

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # isbl.seafile.enable = true;
  # isbl.libsql = {
  #   enable = true;
  #   hostName = "db.isbl.cz";
  #   jwtFile = ./hetzner/jwt.pub;
  # };

  # isbl.kanidm.enable = false;
  # users.users.kanidm = {
  #   isSystemUser = true;
  #   group = "kanidm";
  # };
  # users.groups.kanidm = { };
  # security.acme.certs."kanidm.isbl.cz" = {
  #   domain = "kanidm.isbl.cz";
  #   dnsProvider = "cloudflare";
  #   credentialsFile = config.age.secrets.dnskey.path;
  #   group = "kanidm";
  # };
  # services.kanidm.package = pkgs.kanidm_1_4;
  # environment.persistence."/persistent".directories = [
  #   "/var/lib/kanidm"
  # ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
