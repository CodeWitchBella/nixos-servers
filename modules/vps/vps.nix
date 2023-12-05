{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./authentik.nix
  ];
}
