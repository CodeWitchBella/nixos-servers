{
  pkgs,
  config,
  inputs,
  ...
}: {
  services.sonarr = {
    enable = true;
    dataDir = "/ssd/sonarr";
  };
  services.lidarr = {
    enable = true;
    dataDir = "/ssd/lidarr";
  };
}
