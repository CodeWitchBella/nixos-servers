{
  pkgs,
  config,
  inputs,
  ...
}: {
  virtualisation.oci-containers = {
    backend = "podman";
    containers.filebrowser = {
      image = "filebrowser/filebrowser";
      user = "filebrowser:jellyfin";
      volumes = [
        "/ssd:/srv/ssd"
        "/disks:/srv/disks"
        "/ssd/persistent/filebrowser/filebrowser.db:/database.db"
        "/ssd/persistent/filebrowser/.filebrowser.json:/.filebrowser.json"
      ];
      ports = ["80:3802"];
    };
  };
  users.users.filebrowser = {
    isSystemUser = true;
    extraGroups = ["jellyfin" "lidarr"];
  };
}
