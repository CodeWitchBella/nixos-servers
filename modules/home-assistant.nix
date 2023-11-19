{ config, lib, pkgs, ... }:
{  
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "/disks/homeassistant:/config" ];
      environment.TZ = "Europe/Prague";
      image = "ghcr.io/home-assistant/home-assistant:stable"; # Warning: if the tag does not change, the image will not be updated
      ports = ["127.0.0.1:8123:8123"];
      extraOptions = [ 
        #"--network=host" 
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        "--device=/dev/ttyACM0:/dev/ttyACM0"  # Example, change this to match your own hardware
      ];
    };
  };
}
