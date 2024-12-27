{
  pkgs,
  config,
  inputs,
  ...
}: {
  age.secrets.email-password = {
    file = ../../secrets/email-password.age;
  };
  security.acme = {
    # https://nixos.org/manual/nixos/stable/index.html#module-security-acme-config-dns
    certs."email.isbl.cz" = {
      domain = "email.isbl.cz";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      group = "nginx";
    };
  };
  # https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues/275
  services.dovecot2.sieve.extensions = ["fileinto"];
  mailserver = {
    enable = true;
    fqdn = "email.isbl.cz"; # domain for SMTP/IMAP
    sendingFqdn = "email.isbl.cz"; # rDNS
    domains = ["isbl.cz" "brehoni.cz"];
    dkimSelector = "isbl";

    # Hashes generated with:
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "me@isbl.cz" = {
        hashedPasswordFile = config.age.secrets.email-password.path;
        catchAll = ["isbl.cz"];
      };
      "oddil@brehoni.cz" = {
        hashedPassword = "$2b$05$nJfL3luwkjMD4l7.9JxqEeUjzTr5Xkw0Bl80tnYS.bjsOK8PAkCuO";
        sendOnly = true;
      };
      "authentik@isbl.cz" = {
        hashedPassword = "$2b$05$Q5QhaF3Q1E3uMmn.hw5Vr.8Uk3zamX.K.jtLhcVGXOzid20qoL5f6";
        sendOnly = true;
      };
      "vault@isbl.cz" = {
        hashedPassword = "$2b$05$4NF7DTvf9U1WoM98rC2FxuXEStTalo6mAsLJaHHnrjUHCG/zIjvfq";
        sendOnly = true;
      };
    };
    certificateScheme = "acme";
  };
  services.roundcube = {
    enable = true;
    hostName = "email.isbl.cz";
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };
  services.nginx.virtualHosts."email.isbl.cz" = {
    enableACME = false;
    useACMEHost = "isbl.cz";
  };
  services.rspamd.extraConfig = ''
    actions {
      reject = null; # Disable rejects, default is 15
      add_header = 6; # Add header when reaching this score
      greylist = null; # Apply greylisting when reaching this score
    }
  '';
}
