{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../modules/vps/vps.nix
    ../modules/basics.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
  ];

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=900s
  '';

  time.timeZone = "UTC"; # authentik breaks in local timezone
  networking.firewall.allowedTCPPorts = [22 80 443];
  networking.firewall.allowedUDPPorts = [443];

  system.stateVersion = "23.11";
}
