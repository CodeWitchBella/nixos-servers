{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.isbl.podman-pin;
  json = builtins.fromJSON (builtins.readFile ../podman/images.json);
  decoded = builtins.mapAttrs (
    name: data: {
      image = pkgs.dockerTools.pullImage {
        name = data.repository;
        finalImageTag = data.tag;
        imageDigest = data.digest;
        sha256 = data.sha256;
      };
    }
  ) json;
in
{
  options.isbl.podman-pin =
    with lib;
    mkOption {
      default = { };
      type = types.attrsOf types.str;
    };

  config = {
    isbl.podman-pin = builtins.mapAttrs (ref: mf: mf.${pkgs.system}) decoded;
  };
}
