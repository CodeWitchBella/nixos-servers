{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [ ../nginx.nix ];
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
    };
  };
}
