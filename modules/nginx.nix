{ pkgs, ... }:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@skorepova.info";
    # https://nixos.org/manual/nixos/stable/index.html#module-security-acme-config-dns
    certs."isbl.cz" = {
      domain = "*.isbl.cz";
      dnsProvider = "cloudflare";
      credentialsFile = "/var/lib/secrets/dnskey.conf";
      group = "nginx";
    };
  };
  # https://nixos.org/manual/nixos/stable/options#opt-services.nginx.enable
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic; # http3

    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts =
      let
        host = port: {
          forceSSL = true;
          useACMEHost = "isbl.cz";
          http3 = true;
          quic = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${port}";
            proxyWebsockets = true;
          };
        };
      in
      {
        "ha.isbl.cz" = host "8123";
        "zigbee.isbl.cz" = host "8080";
        "jellyfin.isbl.cz" = host "8096";
        "netdata.isbl.cz" = host "19999";
      };
  };
}
