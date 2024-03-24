{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  systemd.services.tz = {
    path = with pkgs; [openssh];
    script = ''
      cd /var/www/tz
      ${pkgs.git}/bin/git pull
      ${pkgs.zola}/bin/zola build
    '';
    serviceConfig = {
      User = "isabella";
    };
  };
  systemd.timers.tz = {
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "tz.service";
    };
  };

  services.nginx.virtualHosts."tz.isbl.cz" = {
    forceSSL = true;
    useACMEHost = "isbl.cz";
    http3 = true;
    quic = true;
    root = "/var/www/tz/public";
  };
}
