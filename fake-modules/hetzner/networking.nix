{
  pkgs,
  config,
  inputs,
  ...
}: let
  external-mac = "90:1b:0e:de:e6:56";
  ext-if = "et0";
  external-ip = "176.9.41.240";
  external-gw = "176.9.41.255";
  external-ip6 = "2a01:4f8:161:3797::1";
  external-gw6 = "fe80::1";
  external-netmask = 27;
  external-netmask6 = 64;
in {
  # rename the external interface based on the MAC of the interface
  services.udev.extraRules = ''SUBSYSTEM=="net", ATTR{address}=="${external-mac}", NAME="${ext-if}"'';
  networking = {
    interfaces."${ext-if}" = {
      ipv4.addresses = [
        {
          address = external-ip;
          prefixLength = external-netmask;
        }
      ];
      ipv6.addresses = [
        {
          address = external-ip6;
          prefixLength = external-netmask6;
        }
      ];
    };
    defaultGateway6 = {
      address = external-gw6;
      interface = ext-if;
    };
    defaultGateway = external-gw;
  };
}
