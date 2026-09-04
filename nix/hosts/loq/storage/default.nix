{ config, ... }: {
	fileSystems."/arch" = {
		device = "/dev/disk/by-label/arch";
		options = [ "nofail" ];
		fsType = "btrfs";
	};
}
