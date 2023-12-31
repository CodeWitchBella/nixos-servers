let
  # cat ~/.ssh/id_ed25519.pub on IsblAsahi
  asahi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZdRoS3HXiUh77MLq2OczaysE79CK0NZGfHyH+3tBlv";

  # cat ~/.ssh/id_ed25519.pub on IsblDesktop
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrYVxQiKKIzGqLIO+6w6qA1d+E9vR2bFLW0EuT4e6zA";
  users = [desktop asahi];

  # cat /etc/ssh/ssh_host_ed25519_key.pub on data.isbl.cz
  data = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMJNGmuodH5B4vKsG4PE6gh1MbryU/s0WbvmaHhTdh2S";
  # on vps.isbl.cz
  vps = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBGSjrR+WPr379Y2ZjyuSdwTIbiroatryKzPUcUX/RjL";
  systems = [data vps];
in {
  "dnskey.conf.age".publicKeys = users ++ systems;
  "outline.age".publicKeys = users ++ systems;
  "authentik-env.age".publicKeys = users ++ [vps];
  "authentik-outpost-token.age".publicKeys = users ++ [data];
  "email-password.age".publicKeys = users ++ [vps];
  "psn.age".publicKeys = users ++ [data];
  "vaultwarden.age".publicKeys = users ++ [vps];
  "frp.age".publicKeys = users ++ [vps data];
}
