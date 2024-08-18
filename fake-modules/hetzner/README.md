## How to install

from hetzner rescue:

-   first run figure-out-networking.sh
-   then install debian using hetzner installimage script, partitioning doesn't matter much
-   next run: `nix run github:nix-community/nixos-anywhere -- --flake '.#hetzner' root@176.9.41.240`
-   it'll do everything including partition setup
-   but you might need to figure out something with ssh host keys
