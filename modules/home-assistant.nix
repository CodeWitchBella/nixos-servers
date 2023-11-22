{ config, lib, pkgs, ... }:
{
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "/disks/homeassistant:/config" ];
      environment.TZ = "Europe/Prague";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      ports = [ "127.0.0.1:8123:8123" ];
      extraOptions = [
        #"--network=host" 
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        #"--device=/dev/ttyACM0:/dev/ttyACM0"  # Example, change this to match your own hardware
      ];
    };
    containers.mqtt = {
      image = "eclipse-mosquitto:2.0";
      volumes = [ "/disks/mosquitto-data:/mosquitto" ];
      ports = [ "1883:1883" "9001:9001" ];
      cmd = [ "mosquitto" "-c" "/mosquitto/config/mosquitto.conf" ];
      extraOptions = [ "--hostname" "mqtt" ];
    };
    containers.zigbee2mqtt = {
      environment.TZ = "Europe/Prague";
      volumes = [
        "/disks/zigbee2mqtt-data:/app/data"
        "/run/udev:/run/udev:ro"
      ];
      ports = [ "8080:8080" ];
      image = "ghcr.io/koenkk/zigbee2mqtt";
      extraOptions = [
        "--device=/dev/ttyACM0:/dev/ttyACM0"
      ];

    };
  };
  virtualisation.podman.defaultNetwork.settings = { dns_enabled = true; };
}
