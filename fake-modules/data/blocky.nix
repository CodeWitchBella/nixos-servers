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
  systemd.units.blocky.wantedBy = ["nginx.service"];
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
    };
  };
  networking.hosts = {
    "127.0.0.1" = ["darl.ns.cloudflare.com." "lorna.ns.cloudflare.com."];
  };
}
