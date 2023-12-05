{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./home-assistant.nix
    ./nginx.nix
    ./outline.nix
  ];
}
