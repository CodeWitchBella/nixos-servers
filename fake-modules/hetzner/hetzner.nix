{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./impermanence.nix
    ./minecraft.nix
    ./networking.nix
    ./restic.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    tree
  ];

  isbl.postgresql = {
    enable = true;
    databases = ["test"];
  };

  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    25565 # minecraft
    #7000 # frps
  ];
}
