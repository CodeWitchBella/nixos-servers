{
  pkgs,
  config,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true; # it's BuSL
  age.secrets.outline = {
    file = ../../secrets/outline.age;
    owner = "outline";
  };
  services.postgresql.package = pkgs.postgresql_14;
  services.outline = {
    enable = true;
    publicUrl = "https://outline.isbl.cz";
    port = 3801;
    forceHttps = false;
    databaseUrl = "local";
    storage.storageType = "local";
    enableUpdateCheck = false;
    oidcAuthentication = {
      # Parts taken from
      # https://authentik.isbl.cz/application/o/outline/.well-known/openid-configuration
      authUrl = "https://authentik.isbl.cz/application/o/authorize/";
      tokenUrl = "https://authentik.isbl.cz/application/o/token/";
      userinfoUrl = "https://authentik.isbl.cz/application/o/userinfo/";
      clientId = "outline";
      clientSecretFile = config.age.secrets.outline.path;
      scopes = ["openid" "email" "profile"];
      usernameClaim = "preferred_username";
      displayName = "Authentik";
    };
  };
}
