## How to install

from hetzner rescue:

-   first run figure-out-networking.sh
-   then install debian using hetzner installimage script, partitioning doesn't matter much
-   next run: `nix run github:nix-community/nixos-anywhere -- --flake '.#hetzner' root@176.9.41.240`
-   it'll do everything including partition setup
-   but you might need to figure out something with ssh host keys

## Btrfs mirror

Disko seems deficient in this department...

```sh
lsblk # to determine which is the empty one
blkdiscard /dev/sdb3 -v
btrfs device add /dev/sdb3 /
btrfs device scan
btrfs balance start -mconvert=raid1 / # metadata
btrfs balance start -dconvert=raid1 / # data
btrfs filesystem usage -T /
```
