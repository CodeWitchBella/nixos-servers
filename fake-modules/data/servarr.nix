{
  pkgs,
  config,
  inputs,
  lib,
  ...
}: rec {
  services.lidarr = {
    enable = false;
    dataDir = "/ssd/lidarr";
  };
  services.radarr = {
    enable = false;
    dataDir = "/ssd/radarr";
  };
  services.readarr = {
    enable = false;
    dataDir = "/ssd/readarr";
  };
  services.sonarr = {
    enable = false;
    dataDir = "/ssd/sonarr";
  };
  services.prowlarr.enable = false;

  users.groups.jellyfin = {
    name = "jellyfin";
    gid = 997;
  };

  users.users = {
    lidarr = lib.mkIf services.lidarr.enable {
      extraGroups = ["jellyfin"];
      lidarr.uid = 306;
    };
    radarr = lib.mkIf services.radarr.enable {
      extraGroups = ["jellyfin"];
      uid = 275;
    };
    readarr = lib.mkIf services.readarr.enable {
      extraGroups = ["jellyfin"];
      uid = 993;
    };
    sonarr = lib.mkIf services.sonarr.enable {
      extraGroups = ["jellyfin"];
      uid = 274;
    };

    jellyfin.name = "jellyfin";
    jellyfin.uid = 997;
    jellyfin.isSystemUser = true;
    jellyfin.group = "jellyfin";
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
