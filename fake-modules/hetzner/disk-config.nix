# Example to create a bios compatible gpt partition
{lib, ...}: let
  one = "/dev/disk/by-path/pci-0000:00:17.0-ata-2.0";
  two = "/dev/disk/by-path/pci-0000:00:17.0-ata-3.0";
  content = {
    type = "gpt";
    partitions = {
      GRUB_MBR = {
        size = "1M";
        type = "EF02";
      };
      BOOT = {
        size = "1G";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
        };
      };
      mdadm = {
        size = "100%";
        content = {
          type = "mdraid";
          name = "raid1";
        };
      };
    };
  };
in {
  disko.devices.disk = {
    one = {
      inherit content;
      type = "disk";
      device = one;
    };
    two = {
      inherit content;
      type = "disk";
      device = two;
    };
  };
  disko.devices.mdadm = {
    raid1 = {
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "btrfs";
        mountpoint = "/";
      };
    };
  };
  boot.loader.grub.devices = ["/dev/sda" "/dev/sda"];
}
