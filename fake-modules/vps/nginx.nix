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
      proxyPass = "https://127.0.0.1:4444";
      proxyWebsockets = true;
    };
  };
in {
  imports = [../nginx.nix];
  security.acme = {
    # https://nixos.org/manual/nixos/stable/index.html#module-security-acme-config-dns
    certs."isbl.cz" = {
      domain = "isbl.cz";
      extraDomainNames = ["*.isbl.cz"];
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
  services.nginx.virtualHosts."outline.isbl.cz" = toData;
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
}
