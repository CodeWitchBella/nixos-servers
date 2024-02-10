{
  pkgs,
  config,
  inputs,
  ...
}: {
  isbl.mainsail = {
    enable = true;
    hostName = "mainsail.isbl.cz";
    nginx.useACMEHost = "isbl.cz";
    config = import ../shared-data/printers.nix "isbl.cz";
  };
}
