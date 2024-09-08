{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./infra/disk-config.nix
    ./infra/fail2ban.nix
    ./infra/impermanence.nix
    ./infra/networking.nix
    ./infra/nginx.nix
    ./infra/restic.nix
    ./minecraft.nix
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
