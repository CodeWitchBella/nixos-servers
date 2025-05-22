{
  pkgs,
  config,
  inputs,
  ...
}:
{
  services.uptime-kuma = {
    enable = false;
    settings = {
      UPTIME_KUMA_HOST = "127.0.0.1";
      UPTIME_KUMA_PORT = "4005";
    };
  };
}
