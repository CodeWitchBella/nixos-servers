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
  };
  # https://nixos.org/manual/nixos/stable/options#opt-services.nginx.enable
  services.nginx = {
    virtualHosts = let
      host = port: {
        forceSSL = true;
        useACMEHost = "isbl.cz";
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
      "authentik.isbl.cz" = host 9000;
      "ha.isbl.cz" = toData;
      "navidrome.isbl.cz" = toData;
      "jellyfin.isbl.cz" = toData;
      "navidrome-direct.isbl.cz" = toData;
    };
  };
}
