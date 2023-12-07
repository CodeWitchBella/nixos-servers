# Example to create a bios compatible gpt partition
{lib, ...}: {
  disko.devices = {
    disk.emmc = {
      device = "/dev/disk/by-path/platform-fe330000.mmc";
      type = "disk";
      content = {
        type = "gpt";
        partitions.boot = {
          name = "BOOT";
          start = "1MiB";
          size = "4G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        partitions.root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-f"]; # Override existing partition
            # Subvolumes must set a mountpoint in order to be mounted,
            # unless their parent is mounted
            subvolumes = {
              # Subvolume name is different from mountpoint
              "/rootfs" = {
                mountpoint = "/";
              };
              # Subvolume name is the same as the mountpoint
              "/home" = {
                mountOptions = ["compress=zstd"];
                mountpoint = "/home";
              };
              # Parent is not mounted so the mountpoint must be set
              "/nix" = {
                mountOptions = ["compress=zstd" "noatime"];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
    disk.ssd = {
      device = "/dev/disk/by-id/ata-Apacer_AS350_1TB_11EE07381F5B00157340";
      type = "disk";
      content = {
        type = "gpt";
        partitions.ssd = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = ["-f"]; # Override existing partition
            mountpoint = "/ssd_root";
            subvolumes = {
              "/ssd" = {
                mountpoint = "/ssd";
              };
              "/var-lib" = {
                mountpoint = "/var/lib";
              };
              "/var-log" = {
                mountpoint = "/var/log";
              };
            };
          };
        };
      };
    };
  };
}
