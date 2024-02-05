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
  services.prowlarr.enable = true;

  users.groups.jellyfin = {
    name = "jellyfin";
    gid = 997;
  };

  users.users = {
    lidarr.extraGroups = ["jellyfin"];
    lidarr.uid = 306;
    radarr.extraGroups = ["jellyfin"];
    radarr.uid = 275;
    readarr.extraGroups = ["jellyfin"];
    readarr.uid = 993;
    sonarr.extraGroups = ["jellyfin"];
    sonarr.uid = 274;
  };

  users.users.isabella.extraGroups = ["transmission" "jellyfin" "lidarr"];
  services.transmission = {
    enable = true;
    openRPCPort = true;
    package = pkgs.transmission_4;
    settings = {
      rpc-bind-address = "127.0.0.1";
      rpc-host-whitelist-enabled = false;
      incomplete-dir = "/ssd/incomplete";
      incomplete-dir-enabled = true;
      download-dir = "/ssd/download";
    };
  };
  services.navidrome = {
    enable = true;
    settings = {
      ReverseProxyWhitelist = "127.0.0.1/32";
      ReverseProxyUserHeader = "X-authentik-username";
      MusicFolder = "/ssd/music";
    };
  };
}
