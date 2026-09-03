{
  # Installation layout, not a hardware scan. Format the root filesystem as ext4
  # with label "nixos", then replace this file with nixos-generate-config output.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
