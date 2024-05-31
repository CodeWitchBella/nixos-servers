{
  pkgs,
  config,
  inputs,
  ...
}: {
  age.secrets.authentik-outpost-token = {
    file = ../../secrets/authentik-outpost-token.age;
  };
  age.secrets.authentik-ldap-token = {
    file = ../../secrets/authentik-ldap-token.age;
  };
  virtualisation.oci-containers.containers.authentik-outpost = {
    image = "ghcr.io/goauthentik/proxy";
    ports = ["127.0.0.1:9000:9000" "127.0.0.1:9443:9443"];
    environmentFiles = [config.age.secrets.authentik-outpost-token.path];
    environment = {
      AUTHENTIK_HOST = "https://authentik.isbl.cz";
      AUTHENTIK_INSECURE = "false";
    };
    extraOptions = ["--network=host"];
  };

  # virtualisation.oci-containers.containers.authentik-ldap = {
  #   image = "ghcr.io/goauthentik/ldap";

  #   ports = [
  #     "127.0.0.1:389:3389"
  #     "127.0.0.1:636:6636"
  #   ];
  #   environmentFiles = [config.age.secrets.authentik-ldap-token.path];
  #   environment = {
  #     AUTHENTIK_HOST = "https://authentik.isbl.cz";
  #     AUTHENTIK_INSECURE = "true";
  #     #AUTHENTIK_TOKEN = In secret file;
  #   };
  # };
}
