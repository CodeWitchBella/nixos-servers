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

      virtualisation.quadlet =
        let
          networks = config.virtualisation.quadlet.networks;
          pods = config.virtualisation.quadlet.pods;
        in
        {
          autoEscape = true;
          networks = {
            listmonk.networkConfig = {
              driver = "bridge";
            };
          };
          containers.listmonk = {
            containerConfig = {
              image = config.isbl.docker-pin.${image};
              volumes = [
                "/persistent/listmonk/uploads:/uploads"
              ];

              # networks = [ "pasta:--map-gw" ];
              # networks = [ "slirp4netns:allow_host_loopback=true" ];
              # networks = [ networks.listmonk.ref ];
              # environmentFiles = [ config.age.secrets.listmonk.path ];
              publishPorts = [ "127.0.0.1:${builtins.toString port}:${builtins.toString port}" ];
              podmanArgs = [ "--add-host host.containers.internal:host-gateway" ];
              environments = {
                LISTMONK_app__address = "0.0.0.0:${builtins.toString port}";
                LISTMONK_db__host = "host.containers.internal";
                LISTMONK_db__port = "5432";
                LISTMONK_db__user = "listmonk";
                # LISTMONK_db__password 	listmonk
                LISTMONK_db__database = "listmonk";
                LISTMONK_db__ssl_mode = "disable";
              };
              # globalArgs = [ "--install" ];
            };
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
