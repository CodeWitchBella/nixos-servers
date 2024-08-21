{
  pkgs,
  config,
  inputs,
  ...
}: {
  isbl.networking = {
    interface = "enp0s31f6";
    netmask = "255.255.255.0";
  };
  networking.useDHCP = false;
  networking.interfaces.${config.isbl.networking.interface} = {
    ipv4.addresses = [
      {
        address = "176.9.41.240";
        prefixLength = 24;
      }
    ];
    ipv6.addresses = [
      {
        address = "2a01:4f8:161:3797::1";
        prefixLength = 64;
      }
    ];
  };
  networking.defaultGateway = "176.9.41.225";
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = config.isbl.networking.interface;
  };
  networking.nameservers = ["8.8.8.8"];
}
