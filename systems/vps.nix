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

  system.stateVersion = "23.11";
}
