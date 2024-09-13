{
  pkgs,
  config,
  ...
}: {
  age.secrets.restic-hetzner.file = ../../../secrets/restic-hetzner.age;
  age.secrets.restic-hetzner-password.file = ../../../secrets/restic-hetzner-password.age;

  services.restic.backups = {
    remotebackup = {
      initialize = true;
      exclude = [
        "/persistent/@backup-snapshot"
      ];
      passwordFile = config.age.secrets.restic-hetzner-password.path;
      repository = "sftp://u419690-sub1@u419690.your-storagebox.de/";
      paths = [
        "/persistent"
      ];
      extraOptions = [
        "sftp.command='${pkgs.sshpass}/bin/sshpass -f ${config.age.secrets.restic-hetzner.path} -- ssh -4 u419690.your-storagebox.de -l u419690-sub1 -s sftp'"
      ];
      timerConfig = {
        OnCalendar = "02:05";
      };
      backupPrepareCommand = ''
        set -Eeuxo pipefail
        # clean old snapshot
        if btrfs subvolume delete /persistent/@backup-snapshot; then
            echo "WARNING: previous run did not cleanly finish, removing old snapshot"
        fi

        btrfs subvolume snapshot -r /persistent /persistent/@backup-snapshot

        umount /persistent
        mount -t btrfs -o subvol=/persistent/@backup-snapshot /dev/disk/by-partlabel/disk-one-raid2 /persistent
      '';
      backupCleanupCommand = ''
        btrfs subvolume delete /persistent/@backup-snapshot
      '';
    };
  };

  systemd.services.restic-backups-remotebackup = {
    path = with pkgs; [btrfs-progs umount mount];
    serviceConfig.PrivateMounts = true;
  };

  programs.ssh.knownHosts = {
    "u419690.your-storagebox.de".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
  };
}
