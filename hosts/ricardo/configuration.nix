{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./sing-box.nix
    ./tailscale.nix
  ];

  system.stateVersion = "26.05";

  networking.hostName = "ricardo";
  networking.useDHCP = false;
  networking.useNetworkd = true;

  systemd.network.networks."10-uplink" = {
    matchConfig.MACAddress = "00:0d:a3:34:3c:eb";
    address = [ "207.2.122.137/24" ];
    gateway = [ "207.2.122.1" ];
    dns = [
      "8.8.8.8"
      "8.8.4.4"
    ];
    networkConfig.DHCP = "no";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap.enable = true;

  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
      priority = 0;
    }
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.xat = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMyy5imzQ6j9ZQ5HfMIljQxVGqzP8C9CNAVAGsp0CFLf"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker = {
    enable = true;
    logDriver = "local";
    daemon.settings = {
      # Publish ports on loopback unless a service explicitly selects a public address.
      ip = "127.0.0.1";
      default-network-opts.bridge."com.docker.network.bridge.host_binding_ipv4" = "127.0.0.1";
    };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "Sun 04:00" ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    vim
    htop
  ];
}
