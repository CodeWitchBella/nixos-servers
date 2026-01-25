{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.isbl.listmonk;
  image = "docker.io/listmonk/listmonk:latest";
  port = 9432;
in
{
  options.isbl.listmonk = {
    enable = mkEnableOption (lib.mdDoc "");
  };

  config = mkIf cfg.enable (
    let
      databaseUrl = config.isbl.postgresql.databaseUrl.listmonk;
    in
    {
      # age.secrets.listmonk = {
      #   file = ../secrets/listmonk.age;
      # };

      isbl.nginx.proxyPass."list.brehoni.cz" = {
        inherit port;
        acmehost = "brehoni.cz";
      };

      isbl.postgresql = {
        enable = true;
        databases = [ "listmonk" ];
      };

      virtualisation.oci-containers.containers.listmonk = {
        volumes = [
          "/persistent/listmonk/uploads:/uploads"
        ];
        image = config.isbl.podman-pin.listmonk.image;
        imageFile = config.isbl.podman-pin.listmonk.imageFile;
        ports = [ "127.0.0.1:${builtins.toString port}:${builtins.toString port}" ];
        extraOptions = [
          "--add-host" "host.containers.internal:host-gateway"
        ];
        environment = {
          LISTMONK_app__address = "0.0.0.0:${builtins.toString port}";
          LISTMONK_db__host = "host.containers.internal";
          LISTMONK_db__port = "5432";
          LISTMONK_db__user = "listmonk";
          # LISTMONK_db__password 	listmonk
          LISTMONK_db__database = "listmonk";
          LISTMONK_db__ssl_mode = "disable";
        };
      };
  
      systemd.tmpfiles.settings."10-isbl-listmonk" =
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
          "/persistent/listmonk/uploads" = d;
        };
    }
  );
}
