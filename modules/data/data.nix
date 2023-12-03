{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./authentik.nix
    ./disk-config.nix
    ./home-assistant.nix
    ./nginx.nix
    ./outline.nix
  ];
}
