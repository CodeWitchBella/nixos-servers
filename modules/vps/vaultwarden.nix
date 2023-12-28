{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  age.secrets.vaultwarden = {
    file = ../../secrets/vaultwarden.age;
  };
  services.vaultwarden = {
    enable = true;
    environmentFile = config.age.secrets.vaultwarden.path;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      WEBSOCKET_ENABLED = true;
      DOMAIN = "https://vault.isbl.cz";

      SMTP_HOST="email.isbl.cz";
      SMTP_FROM="vault@isbl.cz";
      SMTP_PORT=587;
      SMTP_SECURITY="starttls";
      # In secrets:
      #SMTP_USERNAME=<username>
      #SMTP_PASSWORD=<password>
    };
  };
}
