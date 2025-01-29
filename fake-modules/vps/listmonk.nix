{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  age.secrets.listmonk = {
    file = ../../secrets/listmonk.age;
  };
  services.listmonk = {
    enable = true;
    secretFile = config.age.secrets.listmonk.path;
    settings.app.address = "localhost:9432";
    database.createLocally = true;
    database.mutableSettings = true;
  };
}
