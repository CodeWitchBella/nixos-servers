{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  stateDirectory = "vaultwarden";
  dir = "/var/lib/${stateDirectory}";
in
{
  age.secrets.vaultwarden = {
    file = ../../secrets/vaultwarden.age;
  };
  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden.path;
    config = {
      DATA_FOLDER = dir;
      ROCKET_ADDRESS = "127.0.0.1";
      WEBSOCKET_ENABLED = true;
      DOMAIN = "https://vault.isbl.cz";
      SIGNUPS_ALLOWED = false;
      SHOW_PASSWORD_HINT = false;

      SMTP_HOST = "email.isbl.cz";
      SMTP_FROM = "vault@isbl.cz";
      SMTP_PORT = 587;
      SMTP_SECURITY = "starttls";
      # In secrets:
      #SMTP_USERNAME=<username>
      #SMTP_PASSWORD=<password>
    };
  };
  environment.persistence."/persistent".directories = [ dir ];
  systemd.services.vaultwarden.serviceConfig.StateDirectory = lib.mkForce stateDirectory;
  isbl.nginx.proxyPass."vault.isbl.cz" = {
    acmehost = "isbl.cz";
    port = 8000;
  };

  environment.etc = {
    "fail2ban/filter.d/vaultwarden.local".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      failregex = ^.*?Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
      ignoreregex =
      journalmatch = _SYSTEMD_UNIT=vaultwarden.service
    '';
  };
  services.fail2ban.jails.vaultwarden = {
    settings = {
      enabled = true;
      port = "80,443";
      filter = "vaultwarden";
    };
  };
}
