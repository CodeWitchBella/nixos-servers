{
  pkgs,
  config,
  inputs,
  ...
}: {
  age.secrets.authentik-outpost-token = {
    file = ../../secrets/authentik-outpost-token.age;
  };
  virtualisation.oci-containers.containers.authentik-outpost = {
    image = "ghcr.io/goauthentik/proxy";
    ports = ["9000:9000" "9443:9443"];
    environmentFiles = [config.age.secrets.authentik-outpost-token.path];
    environment = {
      AUTHENTIK_HOST = "https://authentik.isbl.cz";
      AUTHENTIK_INSECURE = "false";
    };
    extraOptions = ["--network=host"];
  };
}
