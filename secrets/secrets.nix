let
  # cat ~/.ssh/id_ed25519.pub on IsblDesktop
  isabella = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrYVxQiKKIzGqLIO+6w6qA1d+E9vR2bFLW0EuT4e6zA";
  users = [ isabella ];

  # cat /etc/ssh/ssh_host_ed25519_key.pub on data.isbl.cz
  data = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDg+C4BYTdAx2BMQgj/5uT64WkJc7o6L7emjjK6UYJ/m";
  systems = [ data ];
in
{
  #"secret1.age".publicKeys = [ user1 system1 ];
}
