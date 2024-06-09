{
  pkgs,
  config,
  inputs,
  ...
}: let
  nginx = {
    forceSSL = true;
    useACMEHost = "skorepova.info";
    http3 = true;
    quic = true;
    root = "${inputs.songbook.packages.x86_64-linux.frontend}";
    locations."= /index.html".extraConfig = ''add_header Cache-Control "no-store,no-cache,must-revalidate";'';
    locations."/" = {
      tryFiles = "$uri $uri/ /index.html";
    };
    locations."/assets" = {};
    locations."~* \"/assets/.*-[a-z0-9]{8}\\.[a-z0-9]+\"" = {};
    locations."/api" = {
      proxyPass = "http://127.0.0.1:5512";
      proxyWebsockets = true;
    };
  };
in {
  #services.postgresql.package = pkgs.postgresql_16;
  services.postgresql.ensureDatabases = ["songbook"];
  services.postgresql.enable = true;
  services.postgresql.ensureUsers = [
    {
      name = "songbook";
      ensureDBOwnership = true;
    }
  ];
  services.postgresql.authentication = pkgs.lib.mkOverride 10 ''
    #type database  DBuser  auth-method
    local all       all     trust
    host  all       songbook     127.0.0.1/32   trust
    host  all       songbook     ::1/128        trust
  '';

  systemd.services = {
    songbook = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      description = "Songbook";
      script = "${inputs.songbook.packages.x86_64-linux.backend}/bin/songbook-backend";
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 15;

        User = "isabella";
        Environment = "POSTGRESQL_URL=postgresql://songbook@localhost/songbook";
      };
    };
  };

  services.nginx.virtualHosts."zpevnik.skorepova.info" = nginx // {useACMEHost = "skorepova.info";};
  #services.nginx.virtualHosts."zpevnik.isbl.cz" = nginx // {useACMEHost = "isbl.cz";};
}
