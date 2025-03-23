{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.isbl.libsql;
  user = "libsql";
in
{
  options.isbl.libsql = with lib; {
    enable = mkEnableOption (mdDoc "libsql server");

    hostName = mkOption {
      type = types.str;
      default = "localhost";
      description = mdDoc "Hostname to serve libsql on";
    };

    acmehost = mkOption {
      default = cfg.hostName;
      type = types.str;
    };

    localhostPort = mkOption {
      type = types.int;
      default = 3010;
    };
    localhostAdminPort = mkOption {
      type = types.int;
      default = 3011;
    };
    jwtFile = mkOption {
      type = types.path;
      description = mdDoc ''
        .pub jwt file generated using
        
        ```
        nix run nixpkgs#step-cli -- crypto keypair jwt.pub jwt.key --kty OKP --curve Ed25519 --no-password --insecure
        ```
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${user} = {
      isSystemUser = true;
      group = user;
    };
    users.groups.${user} = { };

    systemd.tmpfiles.settings."10-isbl-libsql" = {
      "/persistent/libsql" = {
        d = {
          user = user;
          group = user;
          mode = "0755";
        };
      };
    };

    systemd.services.libsql = {
      enable = true;
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = user;
        Group = user;
        PrivateMounts = true;
        WorkingDirectory = "/persistent/libsql";
        ReadOnlyPaths = "/";
        ReadWritePaths = "/persistent/libsql";
        ExecStart = lib.concatStringsSep " " [
          "${lib.getBin pkgs.sqld}/bin/sqld"
          "--enable-namespaces"
          "--admin-listen-addr 127.0.0.1:${toString cfg.localhostAdminPort}"
          "--auth-jwt-key-file ${cfg.jwtFile}"
          "--http-listen-addr 127.0.0.1:${toString cfg.localhostPort}"
        ];
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.hostName}" = {
          forceSSL = true;
          http3 = true;
          quic = true;
          useACMEHost = cfg.acmehost;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.localhostAdminPort}";
            };
          };
        };
        "~^([^.]+)\\.${cfg.hostName}$" = {
          forceSSL = true;
          http3 = true;
          quic = true;
          useACMEHost = cfg.acmehost;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString cfg.localhostPort}";
            };
          };
        };
      };
    };
  };
}
