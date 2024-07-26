{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./authentik-outpost.nix
    ./blocky.nix
    ./disk-config.nix
    ./frpc.nix
    ./home-assistant.nix
    ./mainsail.nix
    #./nextcloud.nix
    ./nginx.nix
    ./outline.nix
    ./servarr.nix
    ./spoolman.nix
  ];
  isbl.inventree = {
    enable = true;
    version = "0.15.6";
    frontendHash = "sha256-oyRvGnZyCmWukjNp7XwqomV0LK0tTZHcdS5OGFjmCqY=";
    hostname = "inventree.local.isbl.cz";
    useACMEHost = "isbl.cz";
    data = "/ssd/persistent/inventree-data";
  };
}
