{
  pkgs,
  config,
  inputs,
  ...
}: {
  isbl.nginx.enable = true;
  isbl.nginx.appendDefaultServerConfig = ''
    location /dns-query {
      proxy_http_version 1.0;
      # proxy_cache doh_cache;
      # proxy_cache_key $scheme$proxy_host$uri$is_args$args$request_body;
      proxy_pass http://127.0.0.1:4003;
    }
  '';
  systemd.units.blocky.wantedBy = ["nginx.service" "frp.service"];
  services.blocky = {
    enable = true;
    settings = {
      ports.dns = "192.168.68.56:53,127.0.0.1:53";
      ports.http = 4003;
      upstreams.init.strategy = "fast";
      upstreams.groups.default = [
        #"1.1.1.1"
        #"1.0.0.1"
        "https://cloudflare-dns.com/dns-query"
        #"8.8.8.8"
        #"8.8.4.4"
        "https://dns.google/dns-query"
        "https://doh.opendns.com/dns-query"
      ];
      blocking.denylists.ads = [
        "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
      ];
      blocking.clientGroupsBlock.default = ["ads"];
      bootstrapDns = [
        {upstream = "https://1.1.1.1/dns-query";}
      ];
      caching.cacheTimeNegative = -1;
      queryLog.type = "none";
      customDNS = {
        mapping = {
          "data.isbl.cz" = "192.168.68.56";
        };
        rewrite = {
          "ha.local.isbl.cz" = "data.isbl.cz";
          "ha.isbl.cz" = "data.isbl.cz";
        };
        zone = ''
          $ORIGIN local.isbl.cz.
          $TTL    3600
          @ CNAME data.isbl.cz.
          priscilla A 192.168.68.78
          tris-lan  A 192.168.68.72
          tris-wifi A 192.168.68.85
          blik-wifi A 192.168.68.79
          * CNAME data.isbl.cz.
        '';
      };
    };
  };
  systemd.services.blocky = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    before = ["nginx.service" "frp.service"]; # my nginx setup requires working dns
    unitConfig.TimeoutStartSec = 60;
  };
  networking.hosts = {
    "127.0.0.1" = ["darl.ns.cloudflare.com." "lorna.ns.cloudflare.com."];
  };
}
