{ modulesPath, pkgs, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  system.stateVersion = "26.05";

  networking.hostName = "ricardo";

  boot.loader.grub.enable = true;

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
