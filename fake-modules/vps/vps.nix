{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./authentik.nix
    ./frps.nix
    ./listmonk.nix
    ./nginx.nix
    ./tz.nix
    ./mailserver.nix
    #./mailserver-stalwart.nix
    ./mainsail.nix
    ./uptime.nix
    ./vaultwarden.nix
  ];
}
