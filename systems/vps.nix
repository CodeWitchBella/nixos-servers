{
  config,
  pkgs,
  ...
}: {
  imports = [
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

  time.timeZone = "Europe/Prague";

  system.stateVersion = "23.11";
}
