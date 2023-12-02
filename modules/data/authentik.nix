{ pkgs, config, inputs, ... }:
{
  age.secrets.authentik-env = {
    file = ../../secrets/authentik-env.age;
  };
  services.authentik = {
    enable = true;
    environmentFile = config.age.secrets.authentik-env.path;
    settings = {
      #email = {
      #  host = "smtp.example.com";
      #  port = 587;
      #  username = "authentik@example.com";
      #  use_tls = true;
      #  use_ssl = false;
      #  from = "authentik@example.com";
      #};
    };
  };
}