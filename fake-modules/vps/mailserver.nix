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
  mailserver = {
    enable = true;
    fqdn = "email.isbl.cz"; # domain for SMTP/IMAP
    sendingFqdn = "email.isbl.cz"; # rDNS
    domains = ["isbl.cz"];

    # Hashes generated with:
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "me@isbl.cz" = {
        hashedPasswordFile = config.age.secrets.email-password.path;
        catchAll = ["isbl.cz"];
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
}
