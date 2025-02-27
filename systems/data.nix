# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let kernelPkgs = import inputs.nixpkgs-data-kernel { system = "aarch64-linux"; }; in
{
  imports = [
    ../fake-modules/data/data.nix
    ../fake-modules/basics.nix
  ];

  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.kernelPackages = kernelPkgs.linuxKernel.packages.linux_6_10;
  boot.initrd = {
    supportedFilesystems = [ "btrfs" ];
    systemd.enable = true;
    systemd.emergencyAccess = true;
    network.ssh.enable = true;
    availableKernelModules = [
      "phy_rockchip_pcie"
      "pcie_rockchip_host"
    ];
  };

  fileSystems."/disks" = {
    device = "/dev/disk/by-label/first-btrfs";
    fsType = "btrfs";
    options = [
      "noatime"
      "compress=zstd"
      "autodefrag"
    ];
  };
  fileSystems."/ssd" = {
    device = "/dev/disk/by-label/ssd";
    fsType = "btrfs";
    options = [
      "noatime"
      "compress=zstd"
      "autodefrag"
      "subvol=/ssd"
    ];
  };
  fileSystems."/ssd_root" = {
    device = "/dev/disk/by-label/ssd";
    fsType = "btrfs";
    options = [
      "noatime"
      "compress=zstd"
      "autodefrag"
    ];
  };
  fileSystems."/var/lib" = {
    device = "/dev/disk/by-label/ssd";
    fsType = "btrfs";
    options = [
      "noatime"
      "compress=zstd"
      "autodefrag"
      "subvol=/var-lib"
    ];
  };
  fileSystems."/var/log" = {
    device = "/dev/disk/by-label/ssd";
    fsType = "btrfs";
    options = [
      "noatime"
      "compress=zstd"
      "autodefrag"
      "subvol=/var-log"
    ];
  };
  fileSystems."/nix" = {
    device = "/dev/disk/by-label/ssd";
    fsType = "btrfs";
    options = [
      "noatime"
      "compress=zstd"
      "autodefrag"
      "subvol=/nix"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    1884
    8123
  ];
  networking.firewall.allowedUDPPorts = [
    53
    443
  ];

  services.fstrim.enable = true;

  networking.nameservers = [
    "127.0.0.1"
    "1.1.1.1"
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    usbutils # lsusb
    lm_sensors # sensors
    bat
    zellij
    librespeed-cli
  ];
  # There is not enough RAM. Let's disable some things :-(
  #services.jellyfin.enable = true;
  #services.netdata.enable = true;

  # services.jellyfin = {
  #   enable = true;
  #   openFirewall = true;
  # };

  system.stateVersion = "23.11";
}
