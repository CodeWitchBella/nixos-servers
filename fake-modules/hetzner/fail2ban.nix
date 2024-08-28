{
  pkgs,
  config,
  ...
}: {
  services.fail2ban = {
    enable = true;
    ignoreIP = ["185.224.112.36" "127.0.0.1" "::1"];
    maxretry = 3;
    bantime-increment = {
      enable = true;
      maxtime = "48h";
    };
  };
  services.openssh.logLevel = "VERBOSE";
}
