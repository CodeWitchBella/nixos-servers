{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.isbl.seafile;
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
      age.secrets.seafile = {
        file = ../secrets/seafile.age;
        mode = "666";
      };

      isbl.mariadb = {
        enable = true;
        databases = [
          "ccnet_db"
          "seafile_db"
          "seahub_db"
        ];
      };
      services.mysql = {
        # note that seafile hard-expects to be able to connect via root user
        initialScript = pkgs.writeText "mysql-init.sql" ''
          CREATE USER IF NOT EXISTS 'seafile'@'localhost';
          CREATE USER IF NOT EXISTS 'seafile'@'%';
          ALTER USER 'seafile'@'localhost' IDENTIFIED BY 'seafilepw';
          ALTER USER 'seafile'@'%' IDENTIFIED BY 'seafilepw';

          CREATE USER IF NOT EXISTS 'root'@'localhost';
          CREATE USER IF NOT EXISTS 'root'@'%';
          ALTER USER 'root'@'localhost' IDENTIFIED BY 'seafilepw';
          ALTER USER 'root'@'%' IDENTIFIED BY 'seafilepw';

          GRANT ALL ON ccnet_db.* TO 'seafile'@'localhost';
          GRANT ALL ON ccnet_db.* TO 'seafile'@'%';
          GRANT ALL ON seafile_db.* TO 'seafile'@'localhost';
          GRANT ALL ON seafile_db.* TO 'seafile'@'%';
          GRANT ALL ON seahub_db.* TO 'seafile'@'localhost';
          GRANT ALL ON seahub_db.* TO 'seafile'@'%';
          FLUSH PRIVILEGES;
        '';
      };

      users.groups.seafile = {};
      users.users.seafile = {
        isSystemUser = true;
        group = "seafile";
      };

      virtualisation.oci-containers = {
        containers.seafile = {
          image = "seafileltd/seafile-mc:12.0-latest";
          volumes = [
            "/persistent/seafile/data:/shared"
          ];
          ports = [
            "127.0.0.1:18000:8000"
            "127.0.0.1:18080:8080"
            "127.0.0.1:18082:8082"
            "127.0.0.1:18083:8083"
          ];
          #JWT_PRIVATE_KEY=`nix run nixpkgs#pwgen -- -s 40 1`
          environmentFiles = [ config.age.secrets.seafile.path ];
          environment = {
            DB_HOST = "host.docker.internal";
            DB_PORT = "3336";
            DB_USER = "seafile";
            DB_ROOT_PASSWD = "seafilepw";
            DB_PASSWORD = "seafilepw";
            SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
            SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
            SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";
            TIME_ZONE = "Europe/Prague";
            INIT_SEAFILE_ADMIN_EMAIL = "email@isbl.cz";
            INIT_SEAFILE_ADMIN_PASSWORD = "changemePlease";
            SEAFILE_SERVER_HOSTNAME = "seafile.isbl.cz";
            SEAFILE_SERVER_PROTOCOL = "http";
            SITE_ROOT = "/";
            NON_ROOT = "false";
            SEAFILE_LOG_TO_STDOUT = "false";
            ENABLE_SEADOC = "false";
            # SEADOC_SERVER_URL = "http://seafile.example.com/sdoc-server";
          };
        };
      };

      services.nginx.virtualHosts."seafile.isbl.cz" = {
        useACMEHost = "isbl.cz";
        forceSSL = true;
        locations = {
          "/".extraConfig = ''
            proxy_pass http://127.0.0.1:18000/;
            proxy_read_timeout 310s;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host $server_name;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Connection "";
            proxy_http_version 1.1;

            client_max_body_size 0;
          '';

          "/seafhttp".extraConfig = ''
              rewrite ^/seafhttp(.*)$ $1 break;
              proxy_pass http://127.0.0.1:18082;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              client_max_body_size 0;
              proxy_read_timeout  36000s;
          '';

          "/notification/ping".extraConfig = ''
              proxy_pass http://127.0.0.1:18083/ping;
          '';

          "/notification".extraConfig = ''
              proxy_pass http://127.0.0.1:18083/;
              proxy_http_version 1.1;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
          '';

          "/seafdav".extraConfig = ''
              rewrite ^/seafdav$ /seafdav/ permanent;
          '';

          "/seafdav/".extraConfig = ''
              proxy_pass         http://127.0.0.1:18080/seafdav/;
              proxy_set_header   Host $host;
              proxy_set_header   X-Real-IP $remote_addr;
              proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header   X-Forwarded-Host $server_name;
              proxy_read_timeout  1200s;
              client_max_body_size 0;
          '';

          "/:dir_browser".extraConfig = ''
              # Logo of WebDAV
              proxy_pass         http://127.0.0.1:18080/:dir_browser;
          '';

          "/media".extraConfig = ''
              root /opt/seafile/seafile-server-latest/seahub;
          '';
        };
      };


      systemd.tmpfiles.settings."10-isbl-seafile" = {
        "/persistent/seafile/data" = {
          d = {
            user = "seafile";
            group = "seafile";
            mode = "0750";
          };
        };
      };

    }
  );
}
