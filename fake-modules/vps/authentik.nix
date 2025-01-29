{
  pkgs,
  config,
  inputs,
  ...
}:
{
  age.secrets.authentik-env = {
    file = ../../secrets/authentik-env.age;
  };
  systemd.services.authentik.wants = [
    "network-online.target"
    "postgresql.service"
    "redis-authentik.service"
  ];

  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentik-env.path;
    settings = {
      email = {
        host = "email.isbl.cz";
        port = 587;
        username = "authentik@isbl.cz";
        use_tls = true;
        use_ssl = false;
        from = "authentik@isbl.cz";
      };
    };
  };
}
