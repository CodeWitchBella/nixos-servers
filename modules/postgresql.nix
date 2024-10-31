{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.isbl.postgresql;
in {
  options.isbl.postgresql = {
    package = mkPackageOption pkgs "postgresql_16" {
      example = "postgresql_16";
    };
    enable = mkEnableOption (lib.mdDoc "default isbl options for postgresql");
    databases = mkOption {
      type = types.listOf types.str;
      default = cfg.databases;
      description = lib.mdDoc "List of databases (and corresponding users) to create.";
    };
    databaseUrl = mkOption {};
  };

  config = mkIf cfg.enable {
    isbl.postgresql.databaseUrl = builtins.listToAttrs (builtins.map (db: {
        name = db;
        value = "postgresql://${db}@127.0.0.1/${db}?sslmode=disable";
      })
      cfg.databases);
    services.postgresqlBackup = {
      enable = true;
      location = "/persistent/postgresql/dumps";
      startAt = "*-*-* 01:35:00"; # restic runs at 2:05, 30 minutes should be enough
      databases = cfg.databases;
    };
    services.postgresql = {
      enable = true;
      package = cfg.package;
      ensureDatabases = cfg.databases;
      ensureUsers =
        map (name: {
          inherit name;
          ensureDBOwnership = true;
        })
        cfg.databases;

      authentication =
        strings.concatMapStringsSep "\n" (name: ''
          #type database  DBuser  auth-method
          host  ${name}       ${name}     127.0.0.1/32   trust
          host  ${name}       ${name}     ::1/128        trust
        '')
        cfg.databases;
      initdbArgs = ["--data-checksums"]; # we'll see if it causes problems...
      # settings.shared_preload_libraries = ["safeupdate"]; # This makes outline fail...
      # extraPlugins = ps: with ps; [pg_safeupdate];
      enableTCPIP = false; # default, but let's be sure

      dataDir = "/persistent/postgresql/data-${cfg.package.psqlSchema}";
    };

    systemd.tmpfiles.settings."10-isbl-postgresql" = let
      dir = {
        d = {
          user = "postgres";
          group = "postgres";
          mode = "0750";
        };
      };
    in {
      "/persistent/postgresql/data-${cfg.package.psqlSchema}" = dir;
      "/persistent/postgresql/dumps" = dir;
    };
  };
}
