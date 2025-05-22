{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.isbl.nginx;
in
{
  options.isbl.nginx = {
    enable = mkEnableOption (lib.mdDoc "default isbl options for nginx");

    appendDefaultServerConfig = mkOption {
      type = types.lines;
      default = "";
      description = lib.mdDoc "Config to append to default server block";
    };

    proxyPass = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            acmehost = mkOption { type = types.str; };
            target = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            port = mkOption { type = types.ints.unsigned; };
          };
        }
      );
    };
  };

  config = mkIf cfg.enable {
    age.secrets.dnskey = {
      file = ../secrets/dnskey.conf.age;
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "acme@isbl.cz";
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

          ${cfg.appendDefaultServerConfig}
        }
      '';

      virtualHosts = builtins.mapAttrs (name: value: {
        forceSSL = true;
        useACMEHost = value.acmehost;
        http3 = true;
        quic = true;
        locations."/" = {
          proxyPass =
            if value.target != null then value.target else "http://127.0.0.1:${toString value.port}";
          proxyWebsockets = true;
        };
      }) cfg.proxyPass;
    };
  };
}
