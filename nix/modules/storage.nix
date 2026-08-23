# Extra disks. aorus-only — the laptop has none of these.
{ ... }:

{
	fileSystems."/arch" = {
		device = "/dev/disk/by-label/arch";
		options = [ "nofail" ];
		fsType = "ext4";
	};
	fileSystems."/windows" = {
		device = "/dev/disk/by-label/Windows";
		options = [ "nofail" ];
		fsType = "ntfs";
	};
	fileSystems."/games" = {
		device = "/dev/disk/by-label/games";
		options = [ "nofail" ];
		fsType = "btrfs";
	};
	fileSystems."/storage/data" = {
		device = "/dev/disk/by-label/data";
		options = [ "nofail" ];
		fsType = "btrfs";
	};
	fileSystems."/storage/2.5" = {
		device = "/dev/disk/by-label/media2.5";
		options = [ "nofail" ];
		fsType = "btrfs";
	};
	fileSystems."/storage/3.5" = {
		device = "/dev/disk/by-label/media3.5";
		options = [ "nofail" ];
		fsType = "btrfs";
	};
}
