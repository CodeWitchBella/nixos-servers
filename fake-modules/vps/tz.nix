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
      function build() {
          git checkout config.toml
          sed -i -e 's/base_url =.*//' config.toml
          mv config.toml t
          echo "base_url = '$1'" > t2
          cat t2 t > config.toml
          rm t t2
          cat config.toml
          zola build
          git checkout config.toml
      }

      git checkout main
      build /

      mkdir -p tmp
      rm -rf tmp
      mv public tmp
      echo '*' > tmp/.gitignore

      for B in `git branch -r | grep -v -- '->' | grep -v -- 'origin/main' | sed 's|  origin/||'`;
      do
          C=`echo $B | tr -cd '[:alnum:]._-'`
          echo "$B -> $C"
          git checkout "origin/$B"
          build "/$C"
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
