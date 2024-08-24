{
  pkgs,
  config,
  inputs,
  ...
}: let
  name = "create-live-5";
  user = "minecraft";
  modpack = pkgs.fetchzip {
    url = "https://cdn.modrinth.com/data/VUmd23oG/versions/QKVowWlC/create-live-5_1.3.2.1-server.zip";
    sha256 = "sha256-UxAtUnMriRgEBB5GndUJ91v5S9448ageCjPGh6fg3x0=";
    stripRoot = false;
  };
in {
  systemd.services.minecraft = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    path = with pkgs; [temurin-jre-bin-20 umount mount bash];

    script = "
      cd /persistent/minecraft/${name}
    
      ls -la
      cp -r ${modpack}/config ${modpack}/kubejs ${modpack}/local .
      chmod -R u+w config kubejs local
      if [ -d world ]; then chmod -R u+w world; fi 
      echo eula=true > eula.txt
      ls -la
      sh ./run.sh
    ";
    serviceConfig = {
      PrivateMounts = true;
      User = user;
      Group = user;
      BindReadOnlyPaths = map (p: "${modpack}/${p}:/persistent/minecraft/${name}/${p}:norbind") [
        # "config"
        "defaultconfigs"
        "default-server.properties"
        # "kubejs"
        "libraries"
        # "local"
        "mods"
        "run.bat"
        "run.sh"
        "user_jvm_args.txt"
      ];
    };
  };

  users.users.${user} = {
    isSystemUser = true;
    group = user;
  };
  users.groups.${user} = {};
  systemd.tmpfiles.settings."10-isbl-minecraft" = let
    dir = {
      d = {
        user = user;
        group = user;
        mode = "0755";
      };
    };
  in {
    "/persistent/minecraft/${name}" = dir;
  };
}
