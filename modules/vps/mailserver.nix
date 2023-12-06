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

    loginAccounts = {
      "me@isbl.cz" = {
        hashedPasswordFile = config.age.secrets.email-password.path;
        catchAll = ["isbl.cz"];
      };
      "authentik@isbl.cz".hashedPassword = "$2b$05$Q5QhaF3Q1E3uMmn.hw5Vr.8Uk3zamX.K.jtLhcVGXOzid20qoL5f6";
    };
    certificateScheme = "acme";
  };
}
