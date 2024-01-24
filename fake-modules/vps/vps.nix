{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./authentik.nix
    ../frp.nix
    ./frps.nix
    ./listmonk.nix
    ./nginx.nix
    ./mailserver.nix
    ./uptime.nix
    ./vaultwarden.nix
  ];
}
