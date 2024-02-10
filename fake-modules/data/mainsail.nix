{
  pkgs,
  config,
  inputs,
  ...
}: {
  isbl.mainsail = {
    enable = true;
    hostName = "mainsail.local.isbl.cz";
    nginx.useACMEHost = "local.isbl.cz";
    config = import ../shared-data/printers.nix "local.isbl.cz";
  };
}
