{
  config,
  lib,
  pkgs,
  ...
}: {
  age.secrets.psn = {
    file = ../../secrets/psn.age;
  };
  virtualisation.oci-containers = {
    backend = "podman";
  };
  virtualisation.podman.defaultNetwork.settings = {dns_enabled = true;};
}
