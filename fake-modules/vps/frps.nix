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
      auth.token = "cahz5CXuXnL9AFRCVcEfeafu8AmN3ezU0DPALNk8";
      #includes = [config.age.secrets.frp.path]; # includes auth.token
    };
  };
}
