{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  net = config.isbl.networking;
  ip = config.networking.interfaces.${net}.ipv4.addresses [0].address;
in {
  boot.initrd.availableKernelModules = [
    "ahci"
    "sd_mod"
    "e1000e" # lspci -v | grep -iA8 'network\|ethernet'
  ];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };

  # We need networking in the initrd
  boot.initrd.network = {
    enable = true;
    postCommands = "sleep 60";
    ssh = {
      enable = true;
      port = 1234;
      hostKeys = ["/nix/secret/initrd/ssh_host_ed25519_key"];
    };
  };

  # Ensure the initrd knows about mdadm
  boot.swraid.enable = true;
  boot.swraid.mdadmConf = ''
    HOMEHOST ${config.networking.hostName}
  '';

  # Now this is hairy! The format is more or less:
  # IP:<ignore>:GATEWAY:NETMASK:HOSTNAME:NIC:AUTCONF?
  # See: https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
  boot.kernelParams = ["ip=176.9.41.240::176.9.41.225:255.255.255.0:hetzner::off"];

  boot.initrd.systemd.network.wait-online.enable = true;

  time.timeZone = "UTC";

  users.mutableUsers = false;
}
