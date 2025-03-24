with (import ./keys.nix);
let
  systems = [
    data
    vps
    hetzner
  ];
  users = [
    desktop
    asahi
  ];
in
{
  "dnskey.conf.age".publicKeys = users ++ systems;
  "outline.age".publicKeys = users ++ [ hetzner ];
  "outline-s3-key.age".publicKeys = users ++ [ hetzner ];
  "outline-secret.age".publicKeys = users ++ [ hetzner ];
  "outline-secret-key.age".publicKeys = users ++ [ hetzner ]; # unused but let's store it just in case
  "authentik-env.age".publicKeys = users ++ [ vps ];
  "authentik-outpost-token.age".publicKeys = users ++ [ data ];
  "authentik-ldap-token.age".publicKeys = users ++ [ data ];
  "email-password.age".publicKeys = users ++ [ vps ];
  "psn.age".publicKeys = users ++ [ data ];
  "vaultwarden.age".publicKeys = users ++ [ hetzner ];
  "frp.age".publicKeys = users ++ [
    vps
    data
  ];
  "isponsorblocktv.json.age".publicKeys = users ++ [ data ];
  "listmonk.age".publicKeys = users ++ [ vps ];
  "planka.age".publicKeys = users ++ [ vps ];
  "ssh_host_ed25519_rescue_key.age".publicKeys = users ++ [ ];
  "restic-hetzner.age".publicKeys = users ++ [ hetzner ];
  "restic-hetzner-password.age".publicKeys = users ++ [ hetzner ];
  "headscale.age".publicKeys = users ++ [ hetzner ];
  "seafile.age".publicKeys = users ++ [ hetzner ];
  "libsql-jwt.key.age".publicKeys = users ++ [ hetzner ];
}
