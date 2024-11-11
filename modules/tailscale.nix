{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.isbl.tailscale;
in {
  options.isbl.tailscale = {
    exitNode = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc "Whether to make this an exit node";
    };
  };

  config = mkIf cfg.exitNode {
    networking.nftables.enable = true;
    services.networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = ["routable"];
        script = ''
          ${lib.getExe pkgs.ethtool} -K venet0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = lib.mkOverride 98 true;
      "net.ipv6.conf.all.forwarding" = lib.mkOverride 98 true;
    };
  };
}
