{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.isbl.kanidm;
  certDir = config.security.acme.certs."${cfg.domain}".directory;
in
{
  options.isbl.kanidm = with lib; {
    enable = mkEnableOption (mdDoc "kanidm server");

    domain = mkOption {
      type = types.str;
      default = "kanidm.isbl.cz";
      description = mdDoc "Domain to serve kanidm on";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.kanidm = {
      isSystemUser = true;
      group = "kanidm";
    };
    users.groups.kanidm = { };
    security.acme.certs."${cfg.domain}" = {
      domain = cfg.domain;
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      group = "kanidm";
    };

    services.kanidm = {
      enableServer = true;
      serverSettings = {
        domain = "${cfg.domain}";
        origin = "https://${cfg.domain}";
        tls_key = "${certDir}/key.pem";
        tls_chain = "${certDir}/fullchain.pem";
      };
    };
  };
}
