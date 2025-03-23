{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  networking = {
    defaultGateway = "172.31.1.1";
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce false;
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "116.202.106.94";
            prefixLength = 32;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a01:4f8:c012:775c::1";
            prefixLength = 64;
          }
          {
            address = "fe80::9400:4ff:fe29:ebd2";
            prefixLength = 64;
          }
        ];
        ipv4.routes = [
          {
            address = "172.31.1.1";
            prefixLength = 32;
          }
        ];
        ipv6.routes = [
          {
            address = "fe80::1";
            prefixLength = 128;
          }
        ];
      };

    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="96:00:04:29:eb:d2", NAME="eth0"
  '';

  networking.nameservers = [
    "8.8.8.8"
  ];
}
