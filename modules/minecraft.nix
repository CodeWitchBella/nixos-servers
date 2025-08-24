{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.isbl.minecraft;
  image = "docker.io/itzg/minecraft-server:latest";
  port = 25565;
  bluemapPort = 8100;
in
{
  options.isbl.minecraft = {
    enable = mkEnableOption (lib.mdDoc "");
    directory = mkOption {
      type = types.str;
      description = lib.mdDoc "Where to store the files";
    };
    cfUrl = mkOption {
      type = types.str;
      description = lib.mdDoc "Where to store the files";
    };
    bluemapDomain = mkOption {
      type = types.nullOr types.str;
      description = lib.mdDoc "Where to host bluemap at";
      default = null;
    };
    bluemapDomainAcme = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = mkIf cfg.enable (
    let
      directory = config.isbl.minecraft.directory;
      networks = config.virtualisation.quadlet.networks;
      pods = config.virtualisation.quadlet.pods;
    in
    {
      age.secrets.minecraft-curseforge = {
        file = ../secrets/minecraft-curseforge.age;
      };
      virtualisation.quadlet = {
        autoEscape = true;
        networks = {
          minecraft.networkConfig = {
            driver = "bridge";
          };
        };
        containers.minecraft = {
          containerConfig = {
            # https://setupmc.com/java-server/ 
            image = config.isbl.docker-pin.${image};
            publishPorts = [
              "${toString port}:${toString port}"
              "${toString bluemapPort}:${toString bluemapPort}"
            ];
            environments = {
              EULA="TRUE";
              TYPE="AUTO_CURSEFORGE";
              CF_PAGE_URL=config.isbl.minecraft.cfUrl;
              INIT_MEMORY="1G";
              MAX_MEMORY="12G";
              MOTD="Isabella's ATM10 Server";
              USE_AIKAR_FLAGS="true";
              TZ="Europe/Prague";
              DIFFICULTY="1"; # 1=easy, 2=normal, 3=hard
              PVP="false";
              ENABLE_WHITELIST="true";
              # Whitelist: sudo podman exec -i minecraft rcon-cli
              # whitelist add <name>
              DISABLE_HEALTHCHECK="true";
            };
            environmentFiles = [
              config.age.secrets.minecraft-curseforge.path
            ];
            volumes = [
              "${directory}:/data"
            ];
          };
        };
      };

      isbl.nginx.proxyPass = mkIf (cfg.bluemapDomain != null) {
        "${cfg.bluemapDomain}" = {
          acmehost = cfg.bluemapDomainAcme;
          port = bluemapPort;
        };
      };

      systemd.tmpfiles.settings."10-isbl-minecraft" =
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
          "${directory}" = d;
        };
    }
  );
}
