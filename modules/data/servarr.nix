{
  pkgs,
  config,
  inputs,
  ...
}: {
  services.lidarr = {
    enable = true;
    dataDir = "/ssd/lidarr";
  };
  services.radarr = {
    enable = true;
    dataDir = "/ssd/radarr";
  };
  services.readarr = {
    enable = true;
    dataDir = "/ssd/readarr";
  };
  services.sonarr = {
    enable = true;
    dataDir = "/ssd/sonarr";
  };
  services.prowlarr = {
    enable = true;
    dataDir = "/ssd/prowlarr";
  };
}
