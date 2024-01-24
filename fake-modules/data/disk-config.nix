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
            extraArgs = [
              # Override existing partition
              "-f"
              # duplicate metadata
              "--metadata"
              "dup"
            ];
            # Subvolumes must set a mountpoint in order to be mounted,
            # unless their parent is mounted
            subvolumes = {
              # Subvolume name is different from mountpoint
              "/rootfs" = {
                mountOptions = ["compress=zstd" "relatime"];
                mountpoint = "/";
              };
              # Subvolume name is the same as the mountpoint
              "/home" = {
                mountOptions = ["compress=zstd" "relatime"];
                mountpoint = "/home";
              };
            };
          };
        };
      };
    };
  };
}
