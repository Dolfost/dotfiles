# PLACEHOLDER — do NOT hand-write this file.
#
# It is machine-generated and describes THIS box's disks, filesystems, initrd
# modules, CPU microcode, etc. Generate the real one on the target hardware:
#
#   during a NixOS install:   sudo nixos-generate-config --root /mnt
#                             (then copy /mnt/etc/nixos/hardware-configuration.nix here)
#   on a running NixOS box:   nixos-generate-config   (writes to /etc/nixos/)
#
# Until you replace it, `nixosConfigurations.daorus` will parse but won't BUILD a
# real system (no fileSystems defined). The Home-Manager side is unaffected.
{ ... }:
{
  # intentionally minimal so the flake still evaluates
}
