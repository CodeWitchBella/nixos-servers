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
    ./vaultwarden.nix
  ];
}
