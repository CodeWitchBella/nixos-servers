{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./impermanence.nix
    ./networking.nix
  ];
}
