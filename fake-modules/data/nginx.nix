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
  services.nginx = let
    proxypass = port:
      if (builtins.typeOf port) == "string"
      then port
      else "http://127.0.0.1:${toString port}";

    hostPublic = port: {
      forceSSL = true;
      useACMEHost = "isbl.cz";
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = proxypass port;
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
    localExtraConfig = ''
      deny 172.18.80.1;
      allow 172.18.80.26/22;
      deny all;
    '';
    hostLocalPublic = port:
      lib.recursiveUpdate (hostPublic port) {
        useACMEHost = "local.isbl.cz";
        locations."/".extraConfig = localExtraConfig;
      };

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

    hostAuth = port: {
      forceSSL = true;
      useACMEHost = "isbl.cz";
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = proxypass port;
        proxyWebsockets = true;
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
    hostLocalAuth = port:
      lib.recursiveUpdate (hostAuth port) {
        useACMEHost = "local.isbl.cz";
        extraConfig = ''
          ${authExtraConfig}
          ${localExtraConfig}
        '';
      };
  in {
    virtualHosts."ha.isbl.cz" = hostPublic 8123;
    virtualHosts."ha.local.isbl.cz" = hostLocalPublic 8123;

    virtualHosts."zigbee.isbl.cz" = host 8080;
    virtualHosts."zigbee.local.isbl.cz" = hostLocalPublic 8080;

    virtualHosts."ps5.isbl.cz" = host 8645;
    virtualHosts."ps5.local.isbl.cz" = hostLocalPublic 8645;

    virtualHosts."jellyfin.isbl.cz" = hostAuth 8096;
    virtualHosts."jellyfin.local.isbl.cz" = hostLocalPublic 8096;

    virtualHosts."netdata.isbl.cz" = host 19999;
    virtualHosts."netdata.local.isbl.cz" = hostLocalPublic 19999;

    virtualHosts."outline.isbl.cz" = hostPublic 3801;
    virtualHosts."outline.local.isbl.cz" = hostLocalPublic 3801;

    virtualHosts."lidarr.isbl.cz" = hostAuth 8686;
    virtualHosts."lidarr.local.isbl.cz" = hostLocalPublic 8686;

    virtualHosts."radarr.isbl.cz" = hostAuth 7878;
    virtualHosts."radarr.local.isbl.cz" = hostLocalPublic 7878;

    virtualHosts."readarr.isbl.cz" = hostAuth 8787;
    virtualHosts."readarr.local.isbl.cz" = hostLocalPublic 8787;

    virtualHosts."sonarr.isbl.cz" = hostAuth 8989;
    virtualHosts."sonarr.local.isbl.cz" = hostLocalPublic 8989;

    virtualHosts."prowlarr.isbl.cz" = hostAuth 9696;
    virtualHosts."prowlarr.local.isbl.cz" = hostLocalPublic 9696;

    virtualHosts."transmission.isbl.cz" = hostAuth 9091;
    virtualHosts."transmission.local.isbl.cz" = hostLocalPublic 9091;

    virtualHosts."navidrome.isbl.cz" = hostAuth 4533;
    virtualHosts."navidrome-direct.isbl.cz" = hostPublic 4533;
    virtualHosts."navidrome.local.isbl.cz" = hostLocalPublic 4533;
    virtualHosts."navidrome-direct.local.isbl.cz" = hostLocalPublic 4533;

    virtualHosts."priscilla.isbl.cz" = hostAuth "http://priscilla.local.isbl.cz";
    virtualHosts."priscilla.local.isbl.cz" = hostLocalPublic "http://priscilla.local.isbl.cz";
  };
}
