# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../modules/data/data.nix
    ../modules/basics.nix
  ];

  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/disks" = {
    device = "/dev/disk/by-label/first-btrfs";
    fsType = "btrfs";
    options = ["noatime" "compress=zstd" "autodefrag"];
  };

  networking.firewall.allowedTCPPorts = [22 80 443];
  networking.firewall.allowedUDPPorts = [443];

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
  services.jellyfin.enable = true;
  services.netdata.enable = true;

  system.stateVersion = "23.11";
}
