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

  isbl.listmonk.enable = true;

  networking.firewall.interfaces."podman1".allowedTCPPorts = [ 5432 ];
  networking.firewall.interfaces."podman0".allowedTCPPorts = [ 5432 ];

  isbl.minecraft = {
    enable = true;
    directory = "/persistent/minecraft/atm-10";
    cfUrl = "https://www.curseforge.com/minecraft/modpacks/all-the-mods-10/files/6550790";
  };

  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https
    25565 # minecraft
    #7000 # frps
  ];
}
