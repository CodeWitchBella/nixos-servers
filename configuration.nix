{ modulesPath, config, lib, pkgs, ... }:
let
  authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMr5ynyyHtVRtoXOCDmyJv4l6JwBWGgt2b4lo1dWLHoW isabella@isbl.cz"];
in
{
  imports = [
    ./disk-config.nix
  ];
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    #devices = [ "/dev/disk/by-path/platform-fe330000.mmc" ];
    device = "nodev";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.openssh.enable = true;

  fileSystems."/disks" =
    {
      device = "/dev/disk/by-label/first-btrfs";
      fsType = "btrfs";
      options = [ "noatime" "compress=zstd" "autodefrag" ];
    };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.vim
  ];

  users.users.root.openssh.authorizedKeys.keys = authorizedKeys;

  system.stateVersion = "23.11";
}