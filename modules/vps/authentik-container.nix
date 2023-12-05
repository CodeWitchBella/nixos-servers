{
  pkgs,
  config,
  inputs,
  ...
}: {
  services.redis.servers.authentik = {
    enable = true;
    port = 6379;
  };
  services.postgresql = {
    enable = true;
    #package = pkgs.postgresql_14;
    ensureDatabases = ["authentik"];
    ensureUsers = [
      {
        name = "authentik";
        ensurePermissions."DATABASE authentik" = "ALL PRIVILEGES";
      }
    ];
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.authentik = {
      image = "ghcr.io/goauthentik/server:2023.10.4"; # TODO: figure out a way to check updates
      environment = {
        AUTHENTIK_REDIS__HOST = "host.containers.internal"; #"redis";
        AUTHENTIK_POSTGRESQL__HOST = ""; #"postgresql";
        AUTHENTIK_POSTGRESQL__USER = "authentik";
        AUTHENTIK_POSTGRESQL__NAME = "authentik"; # db
        #AUTHENTIK_POSTGRESQL__PASSWORD = "${PG_PASS}";
      };
      volumes = [
        "/run/postgresql/.s.PGSQL.5432:/run/postgresql/.s.PGSQL.5432"
        "/data/authentik/media:/media"
        "/data/authentik/custom-templates:/templates"
      ];
      cmd = ["server"];
      ports = ["9000" "9443"];
      extraOptions = [
      ];
    };
  };
}
