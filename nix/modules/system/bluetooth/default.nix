# Bluetooth stack on every host so bluetui always works, but the adapter stays
# powered off at boot.
{ lib, ... }: {
	hardware.bluetooth.enable = true;
	hardware.bluetooth.powerOnBoot = lib.mkDefault false;
}
