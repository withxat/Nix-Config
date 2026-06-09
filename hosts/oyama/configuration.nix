{ pkgs, ... }:

{
  system.stateVersion = "26.05";

  services.openssh.enable = true;
}
