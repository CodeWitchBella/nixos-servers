suffix: {
  defaultLocale = "en";
  instancesDB = "json";
  instances = [
    {
      "hostname" = "priscilla.${suffix}";
      "port" = 443;
    }
    {
      "hostname" = "tris.${suffix}";
      "port" = 443;
    }
  ];
}
