{ pkgs, config, inputs, ... }:
let
  authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMr5ynyyHtVRtoXOCDmyJv4l6JwBWGgt2b4lo1dWLHoW isabella@isbl.cz"];
in
{
  users.users.isabella = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
    shell = pkgs.nushell;
  };
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
  home-manager.users.isabella = import ../home.nix;
}
