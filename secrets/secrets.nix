with (import ./keys.nix); let
  systems = [data vps];
  users = [desktop asahi];
in {
  "dnskey.conf.age".publicKeys = users ++ systems;
  "outline.age".publicKeys = users ++ systems;
  "authentik-env.age".publicKeys = users ++ [vps];
  "authentik-outpost-token.age".publicKeys = users ++ [data];
  "authentik-ldap-token.age".publicKeys = users ++ [data];
  "email-password.age".publicKeys = users ++ [vps];
  "psn.age".publicKeys = users ++ [data];
  "vaultwarden.age".publicKeys = users ++ [vps];
  "frp.age".publicKeys = users ++ [vps data];
  "listmonk.age".publicKeys = users ++ [vps];
  "planka.age".publicKeys = users ++ [vps];
  "ssh_host_ed25519_rescue_key.age".publicKeys = users ++ [];
  "restic-hetzner.age".publicKeys = users ++ [hetzner];
  "restic-hetzner-password.age".publicKeys = users ++ [hetzner];
}
