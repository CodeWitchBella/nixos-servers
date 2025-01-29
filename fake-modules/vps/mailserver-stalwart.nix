{
  pkgs,
  config,
  inputs,
  ...
}:
{
  age.secrets.email-password = {
    file = ../../secrets/email-password.age;
  };

  security.acme = {
    # https://nixos.org/manual/nixos/stable/index.html#module-security-acme-config-dns
    certs."email.isbl.cz" = {
      domain = "email.isbl.cz";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.dnskey.path;
      #group = "stalwart";
    };
  };

  users.groups.stalwart-mail = { };
  users.users.stalwart-mail.group = "stalwart-mail";
  users.users.stalwart-mail.isSystemUser = true;
  users.users.stalwart-mail.extraGroups = [ "acme" ];

  services.postgresql.ensureDatabases = [ "stalwart" ];
  services.postgresql.enable = true;
  services.postgresql.ensureUsers = [
    {
      name = "stalwart";
      ensureDBOwnership = true;
    }
  ];

  services.stalwart-mail = {
    enable = true;
    settings = {
      certificate."isbl" =
        let
          dir = config.security.acme.certs."email.isbl.cz".directory;
        in
        {
          cert = "file://${dir}/cert.pem";
          private-key = "file://${dir}/key.pem";
        };
      server = {
        hostname = "email.isbl.cz";
        tls = {
          certificate = "isbl";
          enable = true;
          implicit = false;
        };
        store.postgresql = {
          type = "postgresql";
          host = "127.0.0.1";
          database = "stalwart";
          user = "stalwart";
        };
        listener = {
          #"smtp" = {
          #  bind = ["[::]:25"];
          #  protocol = "smtp";
          #};
          #"submission" = {
          #  bind = [ "[::]:587" ];
          #  protocol = "smtp";
          #};
          #"imap" = {
          #  bind = [ "[::]:143" ];
          #  protocol = "imap";
          #};
          "http" = {
            bind = [ "127.0.0.1:8183" ];
            protocol = "http";
          };
        };
        session = {
          rcpt.directory = "in-memory";
          auth = {
            mechanisms = [ "PLAIN" ];
            directory = "in-memory";
          };
        };
        jmap.directory = "in-memory";
        queue.outbound.next-hop = [ "local" ];
        directory."in-memory" = {
          type = "memory";
          options.catch-all = true;
          users = [
            {
              name = "me@isbl.cz";
              type = "admin";
              secret = "$2b$05$p/yfC5OUcvHNUbNppf.rP.rZHGgafNBBBtdswTB1Q9GcE0ao24yXK";
              email = [
                "me@isbl.cz"
                "@isbl.cz"
              ];
            }
            {
              name = "authentik@isbl.cz";
              type = "individual";
              secret = "$2b$05$Q5QhaF3Q1E3uMmn.hw5Vr.8Uk3zamX.K.jtLhcVGXOzid20qoL5f6";
              email = [ "authentik@isbl.cz" ];
            }
            {
              name = "vault@isbl.cz";
              type = "individual";
              secret = "$2b$05$4NF7DTvf9U1WoM98rC2FxuXEStTalo6mAsLJaHHnrjUHCG/zIjvfq";
              email = [ "vault@isbl.cz" ];
            }
          ];
        };
      };
    };
  };
}
