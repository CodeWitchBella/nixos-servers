{ pkgs, lib, config, inputs, ... }:
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
    certs."local.isbl.cz" = {
      domain = "*.local.isbl.cz";
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
        hostPublic = port: {
          forceSSL = true;
          useACMEHost = "isbl.cz";
          http3 = true;
          quic = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString(port)}";
            proxyWebsockets = true;
          };
        };
        host = port: lib.recursiveUpdate (hostPublic port) {
          locations."/".extraConfig = ''
            deny 172.18.80.1;
            allow 172.18.80.26/22;
            deny all;
          '';
        };
        hostLocal = port: lib.recursiveUpdate (hostPublic port) {
          useACMEHost = "local.isbl.cz";
        };
      in
      {
        "ha.isbl.cz" = hostPublic 8123;
        "ha.local.isbl.cz" = hostLocal 8123;
        
        "zigbee.isbl.cz" = host 8080;
        "zigbee.local.isbl.cz" = hostLocal 8080;
        
        "jellyfin.isbl.cz" = host 8096;
        "jellyfin.local.isbl.cz" = hostLocal 8096;
        
        "netdata.isbl.cz" = host 19999;
        "netdata.local.isbl.cz" = hostLocal 19999;
        
        "outline.isbl.cz" = hostPublic 3801;
        "outline.local.isbl.cz" = hostLocal 3801;
        
        "dex.isbl.cz" = host 5556;
        "dex.local.isbl.cz" = hostLocal 5556;

        "authentik.isbl.cz" = hostPublic 9000;
        "authentik.local.isbl.cz" = hostLocal 9000;
      };
  };
}
