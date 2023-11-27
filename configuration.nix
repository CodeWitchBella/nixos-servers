# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, inputs, pkgs, ... }:
let
  authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMr5ynyyHtVRtoXOCDmyJv4l6JwBWGgt2b4lo1dWLHoW isabella@isbl.cz"];
in
{
  imports =
    [
      ./modules/outline.nix
      ./modules/home-assistant.nix
      ./modules/nginx.nix
    ];

  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "isabella" ];

  fileSystems."/disks" =
    {
      device = "/dev/disk/by-label/first-btrfs";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd" "autodefrag" ];
    };

  users.users.isabella = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = authorizedKeys;
    shell = pkgs.nushell;
  };
  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
  environment.shells = [ pkgs.nushell ];
  security.sudo.wheelNeedsPassword = false;
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    usbutils # lsusb
    lm_sensors # sensors
    bat
  ];
  environment.variables.EDITOR = "vim";
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  services.jellyfin.enable = true;
  services.netdata.enable = true;

  system.stateVersion = "23.11";
}

