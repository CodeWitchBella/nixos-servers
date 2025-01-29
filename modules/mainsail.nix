{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.isbl.mainsail;
in
{
  options.isbl.mainsail = {
    enable = mkEnableOption (lib.mdDoc "a modern and responsive user interface for Klipper");

    package = mkPackageOption pkgs "mainsail" { };

    hostName = mkOption {
      type = types.str;
      default = "localhost";
      description = lib.mdDoc "Hostname to serve mainsail on";
    };

    config = mkOption { };

    nginx = mkOption {
      default = { };
      example = literalExpression ''
        {
          serverAliases = [ "mainsail.''${config.networking.domain}" ];
        }
      '';
      description = lib.mdDoc "Extra configuration for the nginx virtual host of mainsail.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.hostName}" = mkMerge [
        cfg.nginx
        {
          forceSSL = true;
          http3 = true;
          quic = true;
          root = mkForce "${cfg.package}/share/mainsail";
          locations = {
            "/" = {
              index = "index.html";
              tryFiles = "$uri $uri/ /index.html";
            };
            "/index.html".extraConfig = ''
              add_header Cache-Control "no-store, no-cache, must-revalidate";
            '';
            "/config.json" = {
              root = pkgs.writeTextDir "config.json" (builtins.toJSON cfg.config);
            };
          };
        }
      ];
    };
  };
}
