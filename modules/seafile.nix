{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.isbl.seafile;
  image = "docker.io/seafileltd/seafile-mc:12.0-latest";
  mariadb = "docker.io/library/mariadb:10.11";
in
{
  options.isbl.seafile = {
    enable = mkEnableOption (lib.mdDoc "");
  };

  config = mkIf cfg.enable (
    let
      socket = "unix:/run/seafile/server.sock";
    in
    {
      #JWT_PRIVATE_KEY=`nix run nixpkgs#pwgen -- -s 40 1`
      #MARIADB_ROOT_PASSWORD=`nix run nixpkgs#pwgen -- -s 40 1`
      #DB_ROOT_PASSWD=$MARIADB_ROOT_PASSWORD
      #DB_PASSWORD=`nix run nixpkgs#pwgen -- -s 40 1`
      age.secrets.seafile = {
        file = ../secrets/seafile.age;
        mode = "666";
      };

      isbl.nginx.proxyPass."seafile.isbl.cz" = {
        acmehost = "isbl.cz";
        port = 8881;
      };

      virtualisation.quadlet =
        let
          networks = config.virtualisation.quadlet.networks;
          pods = config.virtualisation.quadlet.pods;
        in
        {
          networks = {
            seafile = { };
          };
          containers.seafile-db = {
            containerConfig = {
              image = config.isbl.docker-pin.${mariadb};
              hostname = "seafile-db";
              environmentFiles = [ config.age.secrets.seafile.path ];
              environments = {
                MYSQL_LOG_CONSOLE = "true";
                MARIADB_AUTO_UPGRADE = "1";
              };
              volumes = [
                "/persistent/seafile/db:/var/lib/mysql"
              ];
              networks = [ networks.seafile.ref ];
              # healthCmd = "/usr/local/bin/healthcheck.sh --connect --mariadbupgrade --innodb_initialized";
              # healthInterval = "20s";
              # healthStartPeriod = "30s";
              # healthTimeout = "5s";
              # healthRetries = 10;
            };
          };

          containers.memcached.containerConfig = {
            image= "memcached:1.6.29";
            hostname = "seafile-memcached";
            entrypoint = "memcached -m 256";
            networks = [ networks.seafile.ref ];
          };

          containers.seafile = {
            containerConfig = {
              image = config.isbl.docker-pin.${image};
              volumes = [
                "/persistent/seafile/data:/shared"
              ];

              environmentFiles = [ config.age.secrets.seafile.path ];
              networks = [ networks.seafile.ref ];
              publishPorts = [ "127.0.0.1:8881:80" ];
              environments = {
                DB_HOST = "seafile-db";
                DB_PORT = "3306";
                DB_USER = "seafile";
                # DB_ROOT_PASSWD="${INIT_SEAFILE_MYSQL_ROOT_PASSWORD:-}";
                # DB_PASSWORD="${SEAFILE_MYSQL_DB_PASSWORD:?Variable is not set or empty}";
                SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
                SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
                SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";
                TIME_ZONE = "Europe/Prague";
                INIT_SEAFILE_ADMIN_EMAIL = "me@isbl.cz";
                INIT_SEAFILE_ADMIN_PASSWORD = "changemePlease";
                SEAFILE_SERVER_HOSTNAME = "seafile.isbl.cz";
                SEAFILE_SERVER_PROTOCOL = "https";
                SITE_ROOT = "/";
                NON_ROOT = "false";
                # JWT_PRIVATE_KEY="${JWT_PRIVATE_KEY:?Variable is not set or empty}";
                SEAFILE_LOG_TO_STDOUT = "false";
                ENABLE_SEADOC = "false";
                SEADOC_SERVER_URL = "http://seafile.example.com/sdoc-server";
              };
            };
          };
        };

      systemd.tmpfiles.settings."10-isbl-seafile" =
        let
          d = {
            d = {
              user = "root";
              group = "root";
              mode = "0777";
            };
          };
        in
        {
          "/persistent/seafile/data" = d;
          "/persistent/seafile/db" = d;
        };

    }
  );
}
