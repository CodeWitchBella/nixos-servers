{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./authentik.nix
    ./listmonk.nix
    ./nginx.nix
    ./planka.nix
    ./tz.nix
    ./mailserver.nix
    #./mailserver-stalwart.nix
    ./mainsail.nix
    ./songbook.nix
    ./uptime.nix
  ];

  services.tailscale.enable = true;
  # isbl.tailscale.exitNode = true;
}
