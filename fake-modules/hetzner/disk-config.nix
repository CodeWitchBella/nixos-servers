# Example to create a bios compatible gpt partition
{lib, ...}: let
  one = "/dev/disk/by-path/pci-0000:00:17.0-ata-2.0";
  two = "/dev/disk/by-path/pci-0000:00:17.0-ata-3.0";
  fullDisk = content: {
    inherit content;
    size = "100%";
  };
  btrfs = {
    type = "btrfs";
    extraArgs = ["-f"]; # Override existing partition
    # Subvolumes must set a mountpoint in order to be mounted,
    # unless their parent is mounted
    subvolumes = {
      "/root" = {
        mountpoint = "/";
      };
      "/persistent" = {
        mountOptions = ["compress=zstd"];
        mountpoint = "/persistent";
      };
      "/nix" = {
        mountOptions = ["compress=zstd" "noatime"];
        mountpoint = "/nix";
      };
    };
  };
  content = disk: {
    type = "gpt";
    partitions = {
      boot = {
        name = "boot";
        size = "1M";
        type = "EF02";
      };
      raid1 = {
        size = "1G";
        content = {
          type = "mdraid";
          name = "braid";
        };
      };
      raid2 =
        if disk == 1
        then fullDisk btrfs
        else
          fullDisk {
            type = "btrfs";
            extraArgs = ["-f"];
            subvolumes = {}; # placeholder for manual edit
          };
    };
  };
in {
  disko.devices.disk = {
    one = {
      content = content 1;
      type = "disk";
      device = one;
    };
    two = {
      content = content 2;
      type = "disk";
      device = two;
    };
  };
  disko.devices.mdadm = {
    braid = {
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/boot";
      };
    };
  };
  fileSystems."/persistent".neededForBoot = true;
  # boot.loader.grub.devices = [one two];
}
