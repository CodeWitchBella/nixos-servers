{
  pkgs,
  config,
  inputs,
  ...
}: {
  age.secrets.authentik-env = {
    file = ../../secrets/authentik-env.age;
  };
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
