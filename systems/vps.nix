{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../fake-modules/vps/vps.nix
    ../fake-modules/basics.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
  ];

  systemd.settings.Manager.DefaultTimeoutStartSec = "900s";

  time.timeZone = "UTC"; # authentik breaks in local timezone
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    143 # imap
    443 # https
    465 # SMTP
    587 # SMTP StartTLS
    993 # imap TLS
    #7000 # frps
  ];
  networking.firewall.allowedUDPPorts = [
    443 # https
    7000 # frps
  ];

  system.stateVersion = "23.11";
}
