{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  systemd.services.tz = {
    path = with pkgs; [openssh git zola];
    script = ''
      set -xe

      cd /var/www/tz
      git checkout main
      zola build

      mkdir -p tmp
      rm -rf tmp
      mv public tmp
      echo '*' > tmp/.gitignore

      for B in `git branch -r | grep -v -- '->' | grep -v -- 'origin/main' | sed 's|  origin/||'`;
      do
          C=`echo $B | tr -cd '[:alnum:]._-'`
          echo "$B -> $C"
          git checkout "origin/$B"
          zola build
          mv public "tmp/$C"
      done

      mkdir -p branches
      rm -rf branches
      mv tmp branches
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
    root = "/var/www/tz/branches";
  };
}
