{
  pkgs,
  config,
  inputs,
  ...
}: let
  dir = "/var/lib/headscale";
in {
  age.secrets.headscale = {
    file = ../../secrets/headscale.age;
    owner = "headscale";
  };
  services.headscale = {
    enable = true;
    port = 8989;
    settings = {
      server_url = "https://headscale.isbl.cz";
      oidc = {
        scope = ["openid" "profile" "email" "offline_access"];
        issuer = "https://authentik.isbl.cz/application/o/headscale/";
        client_id = "W6AE5HPtjz4hrMjIeKEB5nAvDwbcXq0E5SEJQOvZ";
        client_secret_path = config.age.secrets.headscale.path;
      };
      db_path = "${dir}/db.sqlite";
      dns_config.base_domain = "net.isbl.cz";
      # dns_config.magic_dns = false;
    };
  };
  environment.persistence."/persistent".directories = [dir];
  isbl.nginx.proxyPass."headscale.isbl.cz" = {
    acmehost = "isbl.cz";
    port = 8989;
  };
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    tree
  ];
}
