{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.isbl.docker-pin;
  json = builtins.fromJSON (builtins.readFile ../docker-pin.json);
  decoded = builtins.mapAttrs (
    image: manifest:
    builtins.listToAttrs (
      builtins.filter (v: v.name != null) (
        builtins.map (
          mf:
          let
            parsed = lib.strings.splitString ":" image;
            base = builtins.elemAt parsed 0;
            name =
              if mf.platform.architecture == "amd64" then
                "x86_64-linux"
              else if mf.platform.architecture == "arm64" && mf.platform.variant == "v8" then
                "aarch64-linux"
              else
                null;
          in
          {
            inherit name;
            value = "${base}@${mf.digest}";
          }
        ) manifest.manifests
      )
    )
  ) json;
in
{
  options.isbl.docker-pin =
    with lib;
    mkOption {
      default = { };
      type = types.attrsOf types.str;
    };

  config = {
    isbl.docker-pin = builtins.mapAttrs (ref: mf: mf.${pkgs.system}) decoded;
  };
}
