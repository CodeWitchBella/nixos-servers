{
  pkgs,
  config,
  inputs,
  ...
}:
{
  isbl.nginx.enable = true;
  isbl.nginx.appendDefaultServerConfig = ''
    location /dns-query {
      proxy_http_version 1.0;
      # proxy_cache doh_cache;
      # proxy_cache_key $scheme$proxy_host$uri$is_args$args$request_body;
      proxy_pass http://127.0.0.1:4003;
    }
  '';
  systemd.units.blocky.wantedBy = [
    "nginx.service"
    "frp.service"
  ];
  services.blocky = {
    enable = true;
    settings =
      let
        ip = import ../ip.nix;
      in
      {
        ports.dns = "${ip.data}:53,127.0.0.1:53";
        ports.http = 4003;
        upstreams.init.strategy = "fast";
        upstreams.groups.default = [
          "1.1.1.1"
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
        blocking.clientGroupsBlock.default = [ "ads" ];
        bootstrapDns = [
          { upstream = "tcp+udp:1.1.1.1"; }
          { upstream = "https://1.1.1.1/dns-query"; }
        ];
        caching.cacheTimeNegative = -1;
        queryLog.type = "none";
        customDNS = {
          filterUnmappedTypes = false;
          mapping = {
            "data.isbl.cz" = ip.data;
            "zigbee.isbl.cz" = ip.data;
            "ha.isbl.cz" = ip.data;
          };
          zone = ''
            $ORIGIN local.isbl.cz.
            $TTL    3600
            @ CNAME data.isbl.cz.
            priscilla A ${ip.priscilla}
            tris-lan  A ${ip.tris-lan}
            tris-wifi A ${ip.tris-wifi}
            blik-wifi A ${ip.blik-wifi}
            voice     A ${ip.voice}
            homeassistant A ${ip.homeassistant}
            * CNAME data.isbl.cz.
          '';
        };
      };
  };
  systemd.services.blocky = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    before = [
      "nginx.service"
      "frp.service"
    ]; # my nginx setup requires working dns
    # unitConfig.TimeoutStartSec = 60;
  };
  systemd.services.nginx = {
    after = [ "blocky.service" ];
  };
  # networking.hosts = {
  #   "127.0.0.1" = [
  #     "darl.ns.cloudflare.com."
  #     "lorna.ns.cloudflare.com."
  #   ];
  # };
}
