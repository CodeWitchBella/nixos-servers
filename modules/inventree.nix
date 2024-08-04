{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.isbl.inventree;
  frontend = pkgs.fetchzip {
    url = "https://github.com/inventree/InvenTree/releases/download/${cfg.version}/frontend-build.zip";
    hash = cfg.frontendHash;
    stripRoot = false;
  };
in {
  options = {
    isbl.inventree = {
      enable = mkEnableOption "inventree";

      package = mkPackageOption pkgs "frp" {};

      hostname = mkOption {
        type = types.str;
        description = "";
      };
      useACMEHost = mkOption {
        type = types.str;
        description = "";
      };
      data = mkOption {
        type = types.str;
        description = "Location of data directory";
      };
      version = mkOption {
        type = types.str;
        description = "Version to use";
      };
      frontendHash = mkOption {
        type = types.str;
        description = "Hash of frontend assets zip";
      };
      env = mkOption {};
      environmentFiles = mkOption {};
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts.${cfg.hostname} = {
      forceSSL = true;
      useACMEHost = cfg.useACMEHost;
      http3 = true;
      quic = true;
      locations."/static".root = "${cfg.data}";
      locations."/media".root = "${cfg.data}";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
        proxyWebsockets = true;
      };
    };

    services.postgresql.ensureDatabases = ["inventree"];
    services.postgresql.enable = true;
    services.postgresql.ensureUsers = [
      {
        name = "inventree";
        ensureDBOwnership = true;
      }
    ];
    services.postgresql.authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  all       inventree     127.0.0.1/32   trust
      host  all       inventree     ::1/128        trust
    '';

    virtualisation.oci-containers = let
      env =
        {
          # Specify the location of the external data volume
          # By default, placed in local directory 'inventree-data'
          INVENTREE_EXT_VOLUME = "./inventree-data";

          # Ensure debug is false for a production setup
          INVENTREE_DEBUG = "False";
          INVENTREE_LOG_LEVEL = "WARNING";

          # InvenTree admin account details
          # Un-comment (and complete) these lines to auto-create an admin acount
          #INVENTREE_ADMIN_USER="";
          #INVENTREE_ADMIN_PASSWORD="";
          #INVENTREE_ADMIN_EMAIL="";

          # Database configuration options
          INVENTREE_DB_ENGINE = "postgresql";
          INVENTREE_DB_NAME = "inventree";
          INVENTREE_DB_HOST = "localhost";
          INVENTREE_DB_PORT = "5432";

          # Database credentials - These should be changed from the default values!
          INVENTREE_DB_USER = "inventree";
          INVENTREE_DB_PASSWORD = "";

          # Redis cache setup (disabled by default)
          # Un-comment the following lines to enable Redis cache
          # Note that you will also have to run docker-compose with the --profile redis command
          # Refer to settings.py for other cache options
          #INVENTREE_CACHE_ENABLED="True";
          #INVENTREE_CACHE_HOST="inventree-cache";
          #INVENTREE_CACHE_PORT="6379";

          # Options for gunicorn server
          INVENTREE_GUNICORN_TIMEOUT = "90";

          # Enable custom plugins?
          INVENTREE_PLUGINS_ENABLED = "True";

          # Run migrations automatically?
          INVENTREE_AUTO_UPDATE = "True";

          # Image tag that should be used
          INVENTREE_TAG = "stable";

          # Site URL - update this to match your host
          INVENTREE_SITE_URL = "https://${cfg.hostname}";

          COMPOSE_PROJECT_NAME = "inventree";

          INVENTREE_SOCIAL_BACKENDS = "allauth.socialaccount.providers.openid_connect";
        }
        // cfg.env;
    in {
      containers.inventree = {
        volumes = ["${cfg.data}:/home/inventree/data"];
        environment = env;
        image = "inventree/inventree:${cfg.version}";
        #ports = ["127.0.0.1:7773:8000"];
        extraOptions = ["--network=host"];
        environmentFiles = cfg.environmentFiles;
      };
      containers.inventree-worker = {
        volumes = ["${cfg.data}:/home/inventree/data"];
        cmd = ["invoke" "worker"];
        environment = env;
        image = "inventree/inventree:${cfg.version}";
        extraOptions = ["--network=host"];
        environmentFiles = cfg.environmentFiles;
      };
    };
  };
}
