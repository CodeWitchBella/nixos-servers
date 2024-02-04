{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.isbl.frp;
  settingsFormat = pkgs.formats.toml {};
  configFile = settingsFormat.generate "frp.toml" cfg.settings;
  isClient = cfg.role == "client";
  isServer = cfg.role == "server";
in {
  options = {
    isbl.frp = {
      enable = mkEnableOption (mdDoc "frp");

      package = mkPackageOption pkgs "frp" {};

      role = mkOption {
        type = types.enum ["server" "client"];
        description = mdDoc ''
          The frp consists of `client` and `server`. The server is usually
          deployed on the machine with a public IP address, and
          the client is usually deployed on the machine
          where the Intranet service to be penetrated resides.
        '';
      };

      settings = mkOption {
        type = settingsFormat.type;
        default = {};
        description = mdDoc ''
          Frp configuration, for configuration options
          see the example of [client](https://github.com/fatedier/frp/blob/dev/conf/frpc_legacy_full.ini)
          or [server](https://github.com/fatedier/frp/blob/dev/conf/frps_legacy_full.ini) on github.
        '';
        example = literalExpression ''
          {
            common = {
              server_addr = "x.x.x.x";
              server_port = 7000;
            };
          }
        '';
      };
    };
  };

  config = let
    serviceCapability = optionals isServer ["CAP_NET_BIND_SERVICE"];
    executableFile =
      if isClient
      then "frpc"
      else "frps";
  in
    mkIf cfg.enable {
      systemd.services = {
        frp = {
          wants = optionals isClient ["network-online.target"];
          after =
            if isClient
            then ["network-online.target"]
            else ["network.target"];
          wantedBy = ["multi-user.target"];
          description = "A fast reverse proxy frp ${cfg.role}";
          serviceConfig =
            {
              Type = "simple";
              Restart = "on-failure";
              RestartSec = 15;
              ExecStart = "${cfg.package}/bin/${executableFile} -c ${configFile}";
              DynamicUser = true;
              # Hardening
              CapabilityBoundingSet = serviceCapability;
              AmbientCapabilities = serviceCapability;
              PrivateDevices = true;
              ProtectHostname = true;
              ProtectClock = true;
              ProtectKernelTunables = true;
              ProtectKernelModules = true;
              ProtectKernelLogs = true;
              ProtectControlGroups = true;
              RestrictAddressFamilies = ["AF_INET" "AF_INET6"] ++ optionals isClient ["AF_UNIX"];
              LockPersonality = true;
              MemoryDenyWriteExecute = true;
              RestrictRealtime = true;
              RestrictSUIDSGID = true;
              PrivateMounts = true;
              SystemCallArchitectures = "native";
              SystemCallFilter = ["@system-service"];
            }
            // (
              if isServer
              then {
                StateDirectoryMode = "0700";
                UMask = "0077";
              }
              else {}
            );
        };
      };
    };

  meta.maintainers = with maintainers; [zaldnoay];
}
