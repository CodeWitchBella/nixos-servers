{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./nginx.nix
    ./authentik.nix
    ./mailserver.nix
    ./uptime.nix
    ./vaultwarden.nix
  ];
}
