{
  pkgs,
  config,
  inputs,
  ...
}: {
  age.secrets.mailserver-ldap-password = {
    file = ../../secrets/mailserver-ldap-password.age;
  };
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
    domains = [ "isbl.cz" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    #ldap = {
    #  enable = true;
    #  # Test with:
    #  # ldapsearch -x -H ldap://127.0.0.1:3389 -D 'cn=ldap,dc=ldap,dc=goauthentik,dc=io' -w PASSWORD -b 'dc=ldap,dc=goauthentik,dc=io' '(objectClass=*)'
    #  bind.dn = "cn=ldap,dc=ldap,dc=goauthentik,dc=io";
    #  bind.passwordFile = config.age.secrets.mailserver-ldap-password.path;
    #  searchBase = "dc=ldap,dc=goauthentik,dc=io";
    #  uris = ["ldap://127.0.0.1:3389"];
    #};
    loginAccounts = {
      "me@isbl.cz" = {
        hashedPasswordFile = config.age.secrets.email-password.path;
      };
    };
    certificateScheme = "acme";
  };
}
