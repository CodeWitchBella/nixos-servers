# Example to create a bios compatible gpt partition
{lib, ...}: let
  one = "/dev/disk/by-path/pci-0000:00:17.0-ata-2.0";
  two = "/dev/disk/by-path/pci-0000:00:17.0-ata-3.0";
  content = {
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
      raid2 = {
        size = "100%";
        content = {
          type = "mdraid";
          name = "rraid";
        };
      };
    };
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
  luks = {
    size = "100%";
    content = {
      type = "luks";
      name = "crypted";
      settings = {
        allowDiscards = true;
        keyFile = "/tmp/secret.key";
      };
      # additionalKeyFiles = ["/tmp/additionalSecret.key"];
      content = btrfs;
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
    braid = {
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/boot";
      };
    };
    rraid = {
      type = "mdadm";
      level = 1;
      content = btrfs;
    };
  };
  fileSystems."/persistent".neededForBoot = true;
  # boot.loader.grub.devices = [one two];
}
