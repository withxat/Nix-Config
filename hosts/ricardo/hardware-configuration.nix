{
  # Installation layout, not a hardware scan. Label the ext4 root "nixos" and
  # the FAT32 ESP "BOOT", then replace this file with nixos-generate-config output.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };
}
