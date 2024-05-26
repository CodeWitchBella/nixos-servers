{
  pkgs,
  config,
  inputs,
  ...
}: let
  nodejs = pkgs.nodePackages.nodejs;
  source = pkgs.fetchzip {
    url = "https://github.com/plankanban/planka/releases/download/v1.17.4/planka-prebuild-v1.17.4.zip";
    sha256 = "sha256-VG0NyFKqfAZslW7yhvKSXa+HM/+XlFweY6J8eiZ6X5c=";
  };

  pname = "planka";
  version = "1.17.4";
  src = pkgs.stdenv.mkDerivation {
    inherit version;
    pname = "${pname}-patched-src";
    src = source;
    buildPhase = ''
      cp -r . $out
      ${pkgs.jq}/bin/jq '.version = "${version}" | .name = "${pname}"' package.json > $out/package.json
    '';
  };
  planka-npm = pkgs.buildNpmPackage {
    inherit src version;
    pname = "${pname}-npm";

    buildInputs = with pkgs.nodePackages; [
      node-pre-gyp
    ];

    dontNpmBuild = true;
    npmDeps = pkgs.importNpmLock {
      inherit version;
      pname = "${pname}-npm";
      npmRoot = src;
    };
    npmConfigHook = pkgs.importNpmLock.npmConfigHook;
  };
  planka = pkgs.stdenv.mkDerivation {
    inherit version pname;
    src = planka-npm;
    buildPhase = ''
      mkdir -p $out/lib/logs $out/bin
      cp -r lib/node_modules/planka/. $out/lib/
      cat > $out/bin/planka <<-EOL
      #!${pkgs.bash}/bin/sh
      ${nodejs}/bin/node $out/lib/db/init.js
      ${nodejs}/bin/node $out/lib/app.js --prod --port=4448
      EOL
      chmod +x $out/bin/planka
    '';
  };

  nginx = {
    forceSSL = true;
    http3 = true;
    quic = true;
    locations."/" = {
      proxyPass = "https://127.0.0.1:4448";
      proxyWebsockets = true;
    };
  };
in {
  age.secrets.planka = {
    file = ../../secrets/planka.age;
    mode = "666";
  };

  users.users.planka = {
    name = "planka";
    group = "planka";
    isSystemUser = true;
  };
  users.groups.planka = {};

  #services.postgresql.package = pkgs.postgresql_16;
  services.postgresql.ensureDatabases = ["planka"];
  services.postgresql.enable = true;
  services.postgresql.ensureUsers = [
    {
      name = "planka";
      ensureDBOwnership = true;
    }
  ];
  services.postgresql.authentication = pkgs.lib.mkOverride 10 ''
    #type database  DBuser  auth-method
    local all       all     trust
    host  all       planka     127.0.0.1/32   trust
    host  all       planka     ::1/128        trust
  '';

  systemd.services = {
    planka = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      description = "Planka - trello alternative";
      environment = {
        POSTGRESQL_URL = "postgresql://planka@localhost/planka";
        BASE_URL = "https://planka.isbl.cz";
        TRUST_PROXY = "1";
        TZ = "UTC";
        NODE_ENV = "production";

        DEFAULT_ADMIN_EMAIL = "me@isbl.cz"; # Do not remove if you want to prevent this user from being edited/deleted
        DEFAULT_ADMIN_PASSWORD = "YOUR_ADMIN_PASSWORD";
        DEFAULT_ADMIN_NAME = "Isabella";
        DEFAULT_ADMIN_USERNAME = "isbl";
      };
      path = [
        nodejs
      ];
      serviceConfig = {
        Type = "simple";
        User = "planka";
        EnvironmentFile = config.age.secrets.planka.path;
        ExecStart = "${planka}/bin/planka";
      };
    };
  };

  services.nginx.virtualHosts."planka.isbl.cz" = nginx // {useACMEHost = "isbl.cz";};
}
