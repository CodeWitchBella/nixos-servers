{ pkgs, config, inputs, ... }:
{
  nixpkgs.config.allowUnfree = true; # it's BuSL
  services.outline = {
    enable = true;
    publicUrl = "http://localhost:3801";
    port = 3801;
    forceHttps = false;
    databaseUrl = "local";
    storage.storageType = "local";
    enableUpdateCheck = false;
  };
}
