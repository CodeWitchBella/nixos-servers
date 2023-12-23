{
  config,
  lib,
  pkgs,
  ...
}: {
  age.secrets.psn = {
    file = ../../secrets/psn.age;
  };
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = ["/disks/homeassistant:/config"];
      environment.TZ = "Europe/Prague";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      ports = ["127.0.0.1:8123:8123"];
      extraOptions = [
        #"--network=host"
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        #"--device=/dev/ttyACM0:/dev/ttyACM0"  # Example, change this to match your own hardware
      ];
    };
    containers.mqtt = {
      image = "eclipse-mosquitto:2.0";
      volumes = ["/disks/mosquitto-data:/mosquitto"];
      ports = ["1883:1883" "9001:9001"];
      cmd = ["mosquitto" "-c" "/mosquitto/config/mosquitto.conf"];
      extraOptions = ["--hostname" "mqtt"];
    };
    containers.zigbee2mqtt = {
      environment.TZ = "Europe/Prague";
      volumes = [
        "/disks/zigbee2mqtt-data:/app/data"
        "/run/udev:/run/udev:ro"
      ];
      ports = ["8080:8080"];
      image = "ghcr.io/koenkk/zigbee2mqtt";
      extraOptions = [
        "--device=/dev/ttyACM0:/dev/ttyACM0"
        "--network=host" # workaround borked dns
      ];
    };
    containers.ps5mqtt = {
      image = "ghcr.io/funkeyflo/ps5-mqtt/aarch64";
      entrypoint = "/usr/bin/node";
      cmd = ["app/server/dist/index.js"];
      environmentFiles = [config.age.secrets.psn.path];
      extraOptions = [
        "--network=host" # workaround borked dns
      ];
      volumes = ["/ssd/persistent/ps5mqtt:/ssd/persistent/ps5mqtt"];
      environment = {
        MQTT_HOST = "127.0.0.1"; # host.containers.internal if not network=host
        #MQTT_PORT = "1883";
        #MQTT_USERNAME = "mqttuser";
        #MQTT_PASSWORD = "mqttpassword";

        DEVICE_CHECK_INTERVAL = "5000";
        DEVICE_DISCOVERY_INTERVAL = "60000";
        ACCOUNT_CHECK_INTERVAL = "5000";

        #PSN_ACCOUNTS = ''[{"username": "MyPsnUser", "npsso":"npsso_value"}]'';

        INCLUDE_PS4_DEVICES = "false";

        FRONTEND_PORT = "8645";

        CREDENTIAL_STORAGE_PATH = "/ssd/persistent/ps5mqtt/credentials.json";
        CONFIG_PATH = "/data/options.json";
        DEBUG = "@ha:ps5:*";
        DEVICE_DISCOVERY_BROADCAST_ADDRESS = "172.18.80.14";
      };
    };
  };
  virtualisation.podman.defaultNetwork.settings = {dns_enabled = true;};
}
