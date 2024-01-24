{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  age.secrets.dnskey = {
    file = ../secrets/dnskey.conf.age;
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@skorepova.info";
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

      server {
        listen 0.0.0.0:80 default_server;
        listen [::]:80 default_server;
        location / {
          return 301 https://$host$request_uri;
        }
      }
      server {
        listen 0.0.0.0:443 ssl default_server;
        listen [::]:443 ssl default_server;
        listen 0.0.0.0:443 quic default_server;
        listen [::]:443 quic default_server;
        http2 on;
        http3 on;
        http3_hq off;
        ssl_certificate /var/lib/acme/isbl.cz/fullchain.pem;
        ssl_certificate_key /var/lib/acme/isbl.cz/key.pem;
        ssl_trusted_certificate /var/lib/acme/isbl.cz/chain.pem;
        add_header Alt-Svc 'h3=":$server_port"; ma=86400';

        location / {
          return 404;
        }
      }
    '';
  };
}
