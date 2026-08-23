# PLACEHOLDER — do not hand-write this file.
#
# It is machine-generated and describes the laptop's disks, initrd modules, CPU
# microcode and so on. Generate the real one ON the laptop during install:
#
#   sudo nixos-generate-config --root /mnt
#   cp /mnt/etc/nixos/hardware-configuration.nix ~/dotfiles/hosts/loq/
#
# Until you replace it, `nixosConfigurations.loq` EVALUATES but will not BUILD:
# there is no root filesystem and no boot device. That is intentional — it keeps
# the flake valid so `aorus` still works.
#
# The LOQ is a hybrid-graphics laptop; once it is installed, the usual next step
# is adding nixos-hardware as a flake input and importing the module for the
# exact model (see github:NixOS/nixos-hardware).
{ lib, ... }:

{
	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
