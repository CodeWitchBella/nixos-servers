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
  };
  # https://nixos.org/manual/nixos/stable/options#opt-services.nginx.enable
  services.nginx = {
    virtualHosts = let
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
      "authentik.isbl.cz" = host "isbl.cz" 9000;
      "vault.isbl.cz" = host "isbl.cz" 8000;
      "uptime.isbl.cz" = host "isbl.cz" 4005;
      "list.brehoni.cz" = host "brehoni.cz" 9432;
      #"email.isbl.cz" = host "isbl.cz" 8183;

      "ha.isbl.cz" = toData;
      "outline.isbl.cz" = toData;
      "lidarr.isbl.cz" = toData;
      "radarr.isbl.cz" = toData;
      "readarr.isbl.cz" = toData;
      "sonarr.isbl.cz" = toData;
      "prowlarr.isbl.cz" = toData;
      "transmission.isbl.cz" = toData;
      "navidrome.isbl.cz" = toData;
      "navidrome-direct.isbl.cz" = toData;
      "jellyfin.isbl.cz" = toData;
      "priscilla.isbl.cz" = toData;
      "ender.isbl.cz" = toData;
      "spoolman.isbl.cz" = toData;
    };
  };
}
