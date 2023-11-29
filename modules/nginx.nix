{ pkgs, config, inputs, ... }:
{
  age.secrets.dnskey = {
    file = ../secrets/dnskey.conf.age;
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@skorepova.info";
    # https://nixos.org/manual/nixos/stable/index.html#module-security-acme-config-dns
    certs."isbl.cz" = {
      domain = "*.isbl.cz";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
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
    appendHttpConfig = ''
      # Add HSTS header with preloading to HTTPS requests.
      # Adding this header to HTTP requests is discouraged
      map $scheme $hsts_header {
          https   "max-age=31536000; includeSubdomains; preload";
      }
      add_header Strict-Transport-Security $hsts_header;

      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';
    '';

    virtualHosts =
      let
        host = port: {
          forceSSL = true;
          useACMEHost = "isbl.cz";
          http3 = true;
          quic = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString(port)}";
            proxyWebsockets = true;
          };
        };
      in
      {
        "ha.isbl.cz" = host 8123;
        "zigbee.isbl.cz" = host 8080;
        "jellyfin.isbl.cz" = host 8096;
        "netdata.isbl.cz" = host 19999;
        "outline.isbl.cz" = host 3801;
        "dex.isbl.cz" = host 5556;
        "authentik.isbl.cz" = host 9000;
      };
  };
}
