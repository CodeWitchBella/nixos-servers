{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.isbl.networking;
in {
  options = {
    isbl.networking = {
      interface = mkOption {
        type = types.str;
      };
      netmask = mkOption {
        type = types.str;
      };
    };
  };

  config = {};
}
