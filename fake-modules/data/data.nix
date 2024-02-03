{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./authentik-outpost.nix
    ./disk-config.nix
    ../frp.nix
    ./frpc.nix
    ./home-assistant.nix
    #./nextcloud.nix
    ./nginx.nix
    ./outline.nix
    ./servarr.nix
    ./spoolman.nix
  ];
}
