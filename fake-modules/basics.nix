{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
let
  keys = import ../secrets/keys.nix;
  authorizedKeys = with keys; [
    desktop
    asahi
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMr5ynyyHtVRtoXOCDmyJv4l6JwBWGgt2b4lo1dWLHoW isabella@isbl.cz"
  ];
in
{
  nix.package = pkgs.lix;
  users.users.isabella = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
    #shell = pkgs.nushell;
  };
  environment.variables.EDITOR = "vim";
  environment.shells = [ pkgs.nushell ];
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
  home-manager.users.isabella = import ../home.nix;

  security.sudo.wheelNeedsPassword = false;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [ "isabella" ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = lib.mkForce "prohibit-password"; # force needed for making live images
  };

  # nix.settings.extra-substituters = [
  #   "https://cache.lix.systems"
  # ];

  nix.settings.trusted-public-keys = [
    "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
  ];
}
