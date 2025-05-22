{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  host = acmehost: port: {
    forceSSL = true;
    useACMEHost = acmehost;
    http3 = true;
    quic = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
in
{
  isbl.nginx.enable = true;
  security.acme = {
    # https://nixos.org/manual/nixos/stable/index.html#module-security-acme-config-dns
    certs."isbl.cz" = {
      domain = "isbl.cz";
      extraDomainNames = [ "*.isbl.cz" ];
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      group = "nginx";
    };

    certs."db.isbl.cz" = {
      domain = "db.isbl.cz";
      extraDomainNames = [ "*.db.isbl.cz" ];
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      group = "nginx";
    };

    certs."brehoni.cz" = {
      domain = "brehoni.cz";
      extraDomainNames = [ "*.brehoni.cz" ];
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      group = "nginx";
    };
  };
}
