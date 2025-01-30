{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.isbl.mariadb;
in
{
  options.isbl.mariadb = {
    package = mkPackageOption pkgs "mariadb_114" {
      example = "mariadb_114";
    };
    enable = mkEnableOption (lib.mdDoc "default isbl options for mariadb");
    databases = mkOption {
      type = types.listOf types.str;
      default = [];
      description = lib.mdDoc "List of databases to create and backup.";
    };
  };

  config = mkIf cfg.enable {
    services.mysql = {
      enable = true;
      package = cfg.package;
      dataDir = "/persistent/mariadb/data";
      ensureDatabases = cfg.databases;
      settings = {
        mysqld = {
          # and pray that we don't accidentally allow it in firewall :'(
          bind-address = "0.0.0.0";
          port = 3336;
        };
      };
    };

    systemd.tmpfiles.settings."10-isbl-mariadb" = {
      "/persistent/mariadb/data" = {
        d = {
          user = "mysql";
          group = "mysql";
          mode = "0750";
        };
      };
      "/persistent/mariadb/dumps" = {
        d = {
          user = "mysqlbackup";
          group = "mysqlbackup";
          mode = "0750";
        };
      };
    };


    services.mysqlBackup = {
      enable = true;
      location = "/persistent/mariadb/dumps";
      calendar = "01:25:00"; # restic runs at 2:05, postgres dumps at 2:35
      databases = cfg.databases;
      singleTransaction = true;
    };
  };
}
