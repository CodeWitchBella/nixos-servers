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
    role = "server";
    settings = {
      #bindPort = 7000;
      quicBindPort = 7000;
      includes = [config.age.secrets.frp.path]; # includes auth.token
    };
  };
}
