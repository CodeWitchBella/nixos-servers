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

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "24.05"; # Did you read the comment?
}
