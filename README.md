# nixos setup for server

Getting started:

```sh
ssh-keygen
cat ~/.ssh/id_ed25519.pub # set it as deploy key for this repo
git clone git@github.com:CodeWitchBella/nixos-data.git nixos
sudo ln -s /home/isabella/nixos/flake.nix /etc/nixos/
cd nixos
sudo nixos-rebuild switch --flake .
```

You might need to update hardware-configuration.nix

