## Installing configuration on a server

```sh
nix run github:nix-community/nixos-anywhere -- --flake '.#data' root@data.isbl.cz --no-substitute-on-destination
```

## Updating a server

```sh
nixos-rebuild switch --flake .#data --target-host root@data.isbl.cz
```
