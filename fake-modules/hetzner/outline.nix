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
  age.secrets.outline-s3-key = {
    file = ../../secrets/outline-s3-key.age;
    owner = "outline";
  };
  services.outline = {
    enable = true;
    publicUrl = "https://outline.isbl.cz";
    port = 3801;
    forceHttps = false;
    databaseUrl = config.isbl.postgresql.databaseUrl.outline;
    storage = {
      accessKey = "2d6cf57aaff503c156c8588fa46ce0ca";
      secretKeyFile = config.age.secrets.outline-s3-key.path;
      uploadBucketUrl = "https://cce7f3b93d1cc5016fffc6068a30a3bb.eu.r2.cloudflarestorage.com";
      uploadBucketName = "outline";
      region = "auto";
    };
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
  isbl.nginx.proxyPass."outline.isbl.cz" = {
    acmehost = "isbl.cz";
    port = 3801;
  };
  isbl.postgresql = {
    enable = true;
    databases = ["outline"];
  };
}
