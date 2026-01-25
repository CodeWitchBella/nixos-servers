inputs@{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.isbl.podman-pin;
  data = import ../podman/parser.nix inputs;
  hashes = import ../podman/hashes.nix;
  decoded = builtins.map (
    item: {
      name = item.name;
      value = {
        image = "${item.repository}:${item.tag}";
        imageFile = pkgs.dockerTools.pullImage {
          imageName = item.repository;
          finalImageTag = item.tag;
          imageDigest = item.digest;
          sha256 = hashes.${item.name};
        };
      };
    }
  ) data.list;
in
{
  options.isbl.podman-pin =
    with lib;
    mkOption {
      default = { };
      type = types.attrsOf types.attrs;
    };

  config = {
    isbl.podman-pin = builtins.listToAttrs decoded;
  };
}
