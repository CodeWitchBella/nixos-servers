{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../fake-modules/hetzner/hetzner.nix
    ../fake-modules/basics.nix
  ];

  age.secrets.ssh-rescue-key = {
    file = ../secrets/ssh_host_ed25519_rescue_key.age;
  };

  environment.systemPackages = with pkgs; [
    vim
    htop
    git
  ];

  time.timeZone = "UTC";
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
  ];
  networking.firewall.allowedUDPPorts = [
    443 # https
  ];

  boot.initrd = {
    supportedFilesystems.btrfs = true;
    network.ssh = {
      enable = true;
      authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      hostKeys = [config.age.secrets.ssh-rescue-key.path];
    };
  };

  fileSystems."/" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = ["subvol=root"];
  };

  fileSystems."/persistent" = {
    device = "/dev/root_vg/root";
    neededForBoot = true;
    fsType = "btrfs";
    options = ["subvol=persistent"];
  };

  fileSystems."/nix" = {
    device = "/dev/root_vg/root";
    fsType = "btrfs";
    options = ["subvol=nix"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/XXXX-XXXX";
    fsType = "vfat";
  };

  services.fstrim.enable = true;

  services.resolved = {
    enable = true;
    fallbackDns = ["8.8.8.8" "8.8.4.4"];
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];

  system.stateVersion = "24.05";
}
