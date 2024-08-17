{
  pkgs,
  config,
  inputs,
  ...
}: {
  age.secrets.restic-hetzner.file = ../../secrets/restic-hetzner.age;
  age.secrets.restic-hetzner-password.file = ../../secrets/restic-hetzner-password.age;

  services.restic.backups = {
    remotebackup = {
      initialize = true;
      exclude = [
        "/persistent/etc/ssh"
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
        OnCalendar = "00:05";
        RandomizedDelaySec = "5h";
      };
    };
  };

  programs.ssh.knownHosts = {
    "u419690.your-storagebox.de".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
  };
}
