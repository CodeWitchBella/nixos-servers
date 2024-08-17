{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    ../fake-modules/hetzner/hetzner.nix
    ../fake-modules/basics.nix
  ];

  boot.initrd.availableKernelModules = ["ahci" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
