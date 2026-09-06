{
  services.flag = {
    enable = true;
    tailscaleServe = true;
    legacyCatalogDirectory = "/var/lib/flag-catalog/current";
    allowedOrigins = [ "https://ricardo.tail3921e8.ts.net:8443" ];
  };
}
