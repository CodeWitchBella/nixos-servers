{
  pkgs,
  config,
  inputs,
  ...
}: {
  environment.etc."nextcloud-admin-pass".text = "test123";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "nextcloud.local.isbl.cz";
    https = true;
    config.adminpassFile = "/etc/nextcloud-admin-pass";
    extraApps = {
      #socialLogin = pkgs.fetchNextcloudApp rec {
      #  url = "https://github.com/zorn-v/nextcloud-social-login/releases/download/v5.6.1/release.tar.gz";
      #  sha256 = "sha256-sQUsYC3cco6fj9pF2l1NrCEhA3KJoOvJRhXvBlVpNqo=";
      #};
    };
  };

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    forceSSL = true;
    #useACMEHost = "local.isbl.cz";
    useACMEHost = "isbl.cz";
  };
}
