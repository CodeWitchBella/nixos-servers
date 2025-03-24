{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./infra/fail2ban.nix
    ./infra/hardware-configuration.nix
    ./infra/impermanence.nix
    ./infra/networking.nix
    ./infra/nginx.nix
    ./infra/restic.nix
    ./headscale.nix
    ./outline.nix
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
    databases = [ "test" ];
  };

  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https
    25565 # minecraft
    #7000 # frps
  ];
}
