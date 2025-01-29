{
  config,
  lib,
  pkgs,
  ...
}:
{
  virtualisation.oci-containers = {
    containers.spoolman = {
      volumes = [ "/ssd/spoolman:/home/app/.local/share/spoolman" ];
      environment.TZ = "Europe/Prague";
      image = "ghcr.io/donkie/spoolman:latest";
      ports = [ "127.0.0.1:7912:8000" ];
    };
  };
}
