{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./authentik-outpost.nix
    ./disk-config.nix
    ./frpc.nix
    ./home-assistant.nix
    ./mainsail.nix
    #./nextcloud.nix
    ./nginx.nix
    ./outline.nix
    ./servarr.nix
    ./spoolman.nix
  ];
}
