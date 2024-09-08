{
  config,
  lib,
  pkgs,
  ...
}: {
  age.secrets.isponsorblocktv = {
    file = ../../secrets/isponsorblocktv.json.age;
  };
  virtualisation.oci-containers = {
    backend = "podman";
    containers.isponsorblocktv = {
      image = "ghcr.io/dmunozv04/isponsorblocktv";
      volumes = ["${config.age.secrets.isponsorblocktv.path}:/app/data/config.json"];
    };
  };
}
