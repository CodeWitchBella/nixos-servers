# nixos setup for server

This is my server setup. It's a bit hacky and I'd structure it differently if I were to start from scratch, but it works.

**Install:**

```sh
nix run github:nix-community/nixos-anywhere -- --flake '.#data' root@data.isbl.cz --no-substitute-on-destination
# consider setting --copy-host-keys, if relevant
```

**Update:**

```sh
deploy
```
