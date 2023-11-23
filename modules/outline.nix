{ pkgs, config, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true; # it's BuSL
  age.secrets.outline = {
    file = ../secrets/outline.age;
  };
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
      # https://dex.isbl.cz/.well-known/openid-configuration
      authUrl = "https://dex.isbl.cz/auth";
      tokenUrl = "https://dex.isbl.cz/token";
      userinfoUrl = "https://dex.isbl.cz/userinfo";
      clientId = "outline";
      clientSecretFile = config.age.secrets.outline.path;
      scopes = [ "openid" "email" "profile" ];
      usernameClaim = "preferred_username";
      displayName = "Dex";
    };
  };
  services.dex = {
    enable = true;
    settings = {
      issuer = "https://dex.isbl.cz";
      storage = {
        type = "sqlite3";
        config.file = "/var/lib/dex/db.sqlite3";
      };
      web.http = "127.0.0.1:5556";
      staticClients = [
        {
          id = "outline";
          name = "Outline Client";
          redirectURIs = [ "https://outline.isbl.cz/auth/oidc.callback" ];
          secretFile = config.age.secrets.outline.path;
        }
      ];
      connectors = [
        {
          type = "mockPassword";
          id = "isabella";
          name = "Isabella Skořepová";
          config = {
            username = "isbl";
            password = "password";
          };
        }
      ]; 
    };
  };
}
