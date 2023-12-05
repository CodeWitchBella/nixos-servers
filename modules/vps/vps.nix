{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./nginx.nix
    ./authentik.nix
  ];
}
