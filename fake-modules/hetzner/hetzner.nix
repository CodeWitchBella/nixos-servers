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

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    tree
  ];
}
