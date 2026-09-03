{
  services.sing-box = {
    enable = true;
    settings = {
      log.level = "warn";
      inbounds = [
        {
          type = "shadowsocks";
          tag = "from-louise";
          listen = "0.0.0.0";
          listen_port = 443;
          method = "2022-blake3-aes-128-gcm";
          password._secret = "/etc/sing-box/secrets/shadowsocks-password";
        }
      ];
      outbounds = [
        {
          type = "direct";
          tag = "direct";
        }
      ];
      route.final = "direct";
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];
}
