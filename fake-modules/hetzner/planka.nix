{
  config,
  lib,
  pkgs,
  ...
}:
let
  nginx = {
    forceSSL = true;
    http3 = true;
    quic = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:1337";
      proxyWebsockets = true;
    };
  };
in
{
  age.secrets.planka = {
    file = ../../secrets/planka.age;
    mode = "666";
  };

  isbl.postgresql.enable = true;
  isbl.postgresql.databases = ["planka"];
  
  virtualisation.oci-containers = {
    containers.planka = {
      #user = "planka";
      volumes = [
        "/persistent/planka/user-avatars:/app/public/user-avatars"
        "/persistent/planka/project-background-images:/app/public/project-background-images"
        "/persistent/planka/attachments:/app/private/attachments"
      ];
      environmentFiles = [ config.age.secrets.planka.path ];
      environment = {
        POSTGRESQL_URL = "postgres://planka@host.containers.internal/planka";
        BASE_URL = "https://planka.isbl.cz";
        TRUST_PROXY = "1";
        TZ = "UTC";
        NODE_ENV = "production";

        # DEFAULT_ADMIN_EMAIL = "me@isbl.cz";
        # DEFAULT_ADMIN_PASSWORD = "YOUR_ADMIN_PASSWORD";
        # DEFAULT_ADMIN_NAME = "Isabella";
        # DEFAULT_ADMIN_USERNAME = "isbl";

        OIDC_ISSUER = "https://authentik.isbl.cz/application/o/planka/";
        #OIDC_CLIENT_ID= ... in agenix
        #OIDC_CLIENT_SECRET= ... in agenix
        OIDC_SCOPES = "openid profile email";
        OIDC_ADMIN_ROLES = "planka-admin";
        OIDC_ENFORCED = "true";
      };
      image = "ghcr.io/plankanban/planka:latest";
      ports = ["127.0.0.1:4448:1337"];
      extraOptions = [
        "--add-host" "host.containers.internal:host-gateway"
      ];
      # extraOptions = [ "--network=host" ];
    };
  };
  services.nginx.virtualHosts."planka.isbl.cz" = nginx // {
    useACMEHost = "isbl.cz";
  };


  systemd.tmpfiles.settings."10-isbl-planka" =
    let
      dir = {
        d = {
          user = "root";
          group = "root";
          mode = "0777";
        };
      };
    in
    {
      "/persistent/planka/user-avatars" = dir;
      "/persistent/planka/project-background-images" = dir;
      "/persistent/planka/attachments" = dir;
    };
}
