{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    ./authentik-outpost.nix
    ./blocky.nix
    ./disk-config.nix
    ./frpc.nix
    ./home-assistant.nix
    ./mainsail.nix
    #./nextcloud.nix
    ./nginx.nix
    ./outline.nix
    ./servarr.nix
    ./spoolman.nix
  ];
  age.secrets.inventree = {
    file = ../../secrets/inventree.age;
    mode = "666";
  };
  isbl.inventree = {
    enable = true;
    version = "0.15.6";
    frontendHash = "sha256-oyRvGnZyCmWukjNp7XwqomV0LK0tTZHcdS5OGFjmCqY=";
    hostname = "inventree.local.isbl.cz";
    useACMEHost = "isbl.cz";
    data = "/ssd/persistent/inventree-data";
    env = {
      #INVENTREE_EMAIL_BACKEND = ""; # 	email.backend 	Email backend module 	django.core.mail.backends.smtp.EmailBackend
      INVENTREE_EMAIL_HOST = "email.isbl.cz"; # 	email.host 	Email server host 	Not specified
      INVENTREE_EMAIL_PORT = "993"; # 	email.port 	Email server port 	25
      INVENTREE_EMAIL_USERNAME = "inventree@isbl.cz"; # 	email.username 	Email account username 	Not specified
      #INVENTREE_EMAIL_PASSWORD = "viewable-lasso-rural-blasphemy"; # 	email.password 	Email account password 	Not specified
      INVENTREE_EMAIL_TLS = "True"; # 	email.tls 	Enable TLS support 	False
      #INVENTREE_EMAIL_SSL = ""; # 	email.ssl 	Enable SSL support 	False
      INVENTREE_EMAIL_SENDER = "inventree@isbl.cz"; # 	email.sender 	Sending email address 	Not specified
      #INVENTREE_EMAIL_PREFIX = ""; # 	email.prefix 	Prefix for subject text 	[InvenTree]
    };
    environmentFiles = [config.age.secrets.inventree.path];
  };
}
