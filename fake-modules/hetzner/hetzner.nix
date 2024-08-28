{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./fail2ban.nix
    ./impermanence.nix
    ./minecraft.nix
    ./networking.nix
    ./nginx.nix
    ./restic.nix
    ./vaultwarden.nix
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
    443 # https
    25565 # minecraft
    #7000 # frps
  ];
}
