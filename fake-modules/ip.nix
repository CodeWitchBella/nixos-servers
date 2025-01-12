{
  data = "192.168.68.56";
  priscilla = "192.168.68.78";
  tris-lan = "192.168.68.72";
  tris-wifi = "192.168.68.85";
  blik-wifi = "192.168.68.79";
  voice = "192.168.68.67";
  homeassistant = "192.168.68.97";

  lan = "192.168.68.0/22";
  gateway = "192.168.68.1";

  tailscale = {
    homeassistant = "100.64.0.9";
    data = "100.64.0.3";
  };
}
