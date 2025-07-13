{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.isbl.nginx;

  authExtraConfig = ''
    ##############################
    # authentik-specific config
    ##############################
    auth_request     /outpost.goauthentik.io/auth/nginx;
    error_page       401 = @goauthentik_proxy_signin;
    auth_request_set $auth_cookie $upstream_http_set_cookie;
    add_header       Set-Cookie $auth_cookie;

    # translate headers from the outposts back to the actual upstream
    auth_request_set $authentik_username $upstream_http_x_authentik_username;
    auth_request_set $authentik_groups $upstream_http_x_authentik_groups;
    auth_request_set $authentik_email $upstream_http_x_authentik_email;
    auth_request_set $authentik_name $upstream_http_x_authentik_name;
    auth_request_set $authentik_uid $upstream_http_x_authentik_uid;

    proxy_set_header X-authentik-username $authentik_username;
    proxy_set_header X-authentik-groups $authentik_groups;
    proxy_set_header X-authentik-email $authentik_email;
    proxy_set_header X-authentik-name $authentik_name;
    proxy_set_header X-authentik-uid $authentik_uid;
  '';

  protected = {
    locations."/" = {
      extraConfig = authExtraConfig;
    };
    # all requests to /outpost.goauthentik.io must be accessible without authentication
    locations."/outpost.goauthentik.io".extraConfig = ''
      proxy_pass              http://localhost:9000/outpost.goauthentik.io;
      # ensure the host of this vserver matches your external URL you've configured
      # in authentik
      proxy_set_header        Host $host;
      proxy_set_header        X-Original-URL $scheme://$http_host$request_uri;
      add_header              Set-Cookie $auth_cookie;
      auth_request_set        $auth_cookie $upstream_http_set_cookie;
      proxy_pass_request_body off;
      proxy_set_header        Content-Length "";
    '';
    # Special location for when the /auth endpoint returns a 401,
    # redirect to the /start URL which initiates SSO
    locations."@goauthentik_proxy_signin".extraConfig = ''
      internal;
      add_header Set-Cookie $auth_cookie;
      return 302 /outpost.goauthentik.io/start?rd=$request_uri;
      # For domain level, use the below error_page to redirect to your authentik server with the full redirect path
      # return 302 https://authentik.isbl.cz/outpost.goauthentik.io/start?rd=$scheme://$http_host$request_uri;
    '';
  };
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
            protect = mkOption { type = types.bool; default = false; };
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

      virtualHosts = builtins.mapAttrs (
        name: value:
        let
          basic = {
            forceSSL = true;
            useACMEHost = value.acmehost;
            http3 = true;
            quic = true;
            locations."/" = {
              proxyPass =
                if value.target != null then value.target else "http://127.0.0.1:${toString value.port}";
              proxyWebsockets = true;
            };
          };
        in
        if value.protect then protected // basic else basic
      ) cfg.proxyPass;
    };
  };
}
