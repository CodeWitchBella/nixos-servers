{
  pkgs,
  config,
  inputs,
  ...
}: {
  age.secrets.frp = {
    file = ../../secrets/frp.age;
    mode = "666";
    path = "/etc/frp/token.toml";
  };
  isbl.frp = {
    enable = true;
    role = "client";
    settings = {
      role = "client";
      serverAddr = "vps.isbl.cz";
      serverPort = 7000;
      transport.protocol = "quic";
      includes = [config.age.secrets.frp.path]; # includes auth.token

      proxies = [
        {
          name = "data-https";
          type = "tcp";
          localIP = "127.0.0.1";
          localPort = 443;
          remotePort = 4444;
        }
      ];
    };
  };
  users.users.frp = {
    isSystemUser = true;
    group = "frp";
  };
  users.groups.frp = {};
}
