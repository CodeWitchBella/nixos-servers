{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./authentik-outpost.nix
    ./blocky.nix
    ./disk-config.nix
    ./home-assistant.nix
    ./isponsorblocktv.nix
    ./mainsail.nix
    #./nextcloud.nix
    ./nginx.nix
    ./servarr.nix
    ./spoolman.nix
  ];

  services.tailscale.enable = true;
  isbl.tailscale.exitNode = true;
}
