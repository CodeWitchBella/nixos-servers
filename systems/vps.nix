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
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    143 # imap
    443 # https
    465 # SMTP
    587 # SMTP StartTLS
    993 # imap TLS
  ];
  networking.firewall.allowedUDPPorts = [443];

  system.stateVersion = "23.11";
}
