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
    ./mailserver.nix
    #./mailserver-stalwart.nix
    ./uptime.nix
    ./vaultwarden.nix
  ];
}
