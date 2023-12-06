{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [../nginx.nix];
  security.acme = {
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
    virtualHosts = let
      hostPublic = port: {
        forceSSL = true;
        useACMEHost = "isbl.cz";
        http3 = true;
        quic = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
        };
      };
      host = port:
        lib.recursiveUpdate (hostPublic port) {
          locations."/".extraConfig = ''
            deny 172.18.80.1;
            allow 172.18.80.26/22;
            deny all;
          '';
        };
      hostLocal = port:
        lib.recursiveUpdate (hostPublic port) {
          useACMEHost = "local.isbl.cz";
        };

      hostAuth = port: {
        forceSSL = true;
        useACMEHost = "isbl.cz";
        http3 = true;
        quic = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          proxyWebsockets = true;
          extraConfig = ''
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
    in {
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

      "lidarr.isbl.cz" = hostAuth 8686;
      "lidarr.local.isbl.cz" = hostLocal 8686;

      "radarr.isbl.cz" = hostAuth 7878;
      "radarr.local.isbl.cz" = hostLocal 7878;

      "readarr.isbl.cz" = hostAuth 8787;
      "readarr.local.isbl.cz" = hostLocal 8787;

      "sonarr.isbl.cz" = hostAuth 8989;
      "sonarr.local.isbl.cz" = hostLocal 8989;

      "prowlarr.isbl.cz" = hostAuth 9696;
      "prowlarr.local.isbl.cz" = hostLocal 9696;

      "transmission.isbl.cz" = hostAuth 9091;
      "transmission.local.isbl.cz" = hostLocal 9091;
    };
  };
}
