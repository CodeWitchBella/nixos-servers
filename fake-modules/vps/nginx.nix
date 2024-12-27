{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
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

  toData = {
    forceSSL = true;
    useACMEHost = "isbl.cz";
    http3 = true;
    quic = true;
    locations."/" = {
      proxyPass = "https://100.64.0.3";
      proxyWebsockets = true;
    };
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
  hostAuth = target: {
    forceSSL = true;
    useACMEHost = "isbl.cz";
    http3 = true;
    quic = true;
    locations."/" = {
      proxyPass = target;
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
in {
  isbl.nginx.enable = true;
  security.acme = {
    # https://nixos.org/manual/nixos/stable/index.html#module-security-acme-config-dns
    certs."isbl.cz" = {
      domain = "isbl.cz";
      extraDomainNames = ["*.local.isbl.cz" "*.isbl.cz"];
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      group = "nginx";
    };
    certs."brehoni.cz" = {
      domain = "brehoni.cz";
      extraDomainNames = ["*.brehoni.cz"];
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      group = "nginx";
    };
    certs."skorepova.info" = {
      domain = "skorepova.info";
      extraDomainNames = ["*.skorepova.info"];
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      group = "nginx";
    };
  };
  # https://nixos.org/manual/nixos/stable/options#opt-services.nginx.enable
  services.nginx.virtualHosts."authentik.isbl.cz" = host "isbl.cz" 9000;
  services.nginx.virtualHosts."vault.isbl.cz" = host "isbl.cz" 8000;
  services.nginx.virtualHosts."uptime.isbl.cz" = host "isbl.cz" 4005;
  services.nginx.virtualHosts."list.brehoni.cz" = host "brehoni.cz" 9432;
  #services.nginx.virtualHosts."email.isbl.cz" = host "isbl.cz" 8183;

  services.nginx.virtualHosts."ha.isbl.cz" = toData;
  services.nginx.virtualHosts."lidarr.isbl.cz" = toData;
  services.nginx.virtualHosts."radarr.isbl.cz" = toData;
  services.nginx.virtualHosts."readarr.isbl.cz" = toData;
  services.nginx.virtualHosts."sonarr.isbl.cz" = toData;
  services.nginx.virtualHosts."prowlarr.isbl.cz" = toData;
  services.nginx.virtualHosts."transmission.isbl.cz" = toData;
  services.nginx.virtualHosts."navidrome.isbl.cz" = toData;
  services.nginx.virtualHosts."navidrome-direct.isbl.cz" = toData;
  services.nginx.virtualHosts."jellyfin.isbl.cz" = toData;
  services.nginx.virtualHosts."priscilla.isbl.cz" = toData;
  services.nginx.virtualHosts."tris.isbl.cz" = toData;
  services.nginx.virtualHosts."ender.isbl.cz" = toData;
  services.nginx.virtualHosts."spoolman.isbl.cz" = toData;

  services.nginx.virtualHosts."rspamd.isbl.cz" = hostAuth "http://unix:/run/rspamd/worker-controller.sock:/";
}
