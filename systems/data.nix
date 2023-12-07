# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../modules/data/data.nix
    ../modules/basics.nix
  ];

  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd = {
    supportedFilesystems = ["btrfs"];
    systemd.enable = true;
    systemd.emergencyAccess = true;
    network.ssh.enable = true;
    #kernelModules = ["phy_rockchip_pcie"];
    availableKernelModules = [
      "cdc_acm"
      "xt_addrtype"
      "xt_nat"
      "xt_mark"
      "xt_comment"
      "nft_chain_nat"
      "xt_MASQUERADE"
      "veth"
      "wireguard"
      "overlay"
      "8021q"
      "snd_soc_hdmi_codec"
      "dw_hdmi_i2s_audio"
      "dw_hdmi_cec"
      "nls_iso8859_1"
      "snd_soc_simple_card"
      "crct10dif_ce"
      "polyval_ce"
      "sm4"
      "nls_cp437"
      "rk3399_dmc"
      "hci_uart"
      "rockchipdrm"
      "phy_rockchip_pcie"
      "hantro_vpu"
      "btsdio"
      "snd_soc_rockchip_i2s"
      "panfrost"
      "rockchip_vdec"
      "rockchip_rga"
      "brcmfmac"
      "rockchip_dfi"
      "rtc_rk808"
      "dwmac_rk"
      "rockchip_thermal"
      "rockchip_saradc"
      "pcie_rockchip_host"
      "uas"
      "uio_pdrv_genirq"
      "xt_conntrack"
      "ip6t_rpfilter"
      "ipt_rpfilter"
      "xt_pkttype"
      "xt_LOG"
      "nf_log_syslog"
      "xt_tcpudp"
      "nft_compat"
      "sch_fq_codel"
      "tap"
      "macvlan"
      "bridge"
      "fuse"
      "dmi_sysfs"
      "ip_tables"
      "dm_mod"
      "btrfs"
      "blake2b_generic"
    ];
  };

  fileSystems."/disks" = {
    device = "/dev/disk/by-label/first-btrfs";
    fsType = "btrfs";
    options = ["noatime" "compress=zstd" "autodefrag"];
  };
  fileSystems."/ssd" = {
    device = "/dev/disk/by-label/ssd";
    fsType = "btrfs";
    options = ["noatime" "compress=zstd" "autodefrag" "subvol=/ssd"];
  };

  networking.firewall.allowedTCPPorts = [22 80 443];
  networking.firewall.allowedUDPPorts = [443];

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    usbutils # lsusb
    lm_sensors # sensors
    bat
  ];
  services.jellyfin.enable = true;
  services.netdata.enable = true;

  system.stateVersion = "23.11";
}
