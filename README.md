# nixos setup for server

**Install:**

```sh
nix run github:nix-community/nixos-anywhere -- --flake '.#data' root@data.isbl.cz --no-substitute-on-destination
# consider setting --copy-host-keys, if relevant
```

**Update:**

```sh
deploy
```
