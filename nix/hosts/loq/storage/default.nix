{ config, ... }: {
	fileSystems."/arch" = {
		device = "/dev/disk/by-label/arch";
		options = [ "nofail" ];
		fsType = "btrfs";
	};
	fileSystems."/data" = {
		device = "/dev/disk/by-label/data";
		options = [ "nofail" ];
		fsType = "btrfs";
	};
	home-manager.users.${config.dotfiles.user} = { config, ... }: {
		home.file = {
			"data".source =
				config.lib.file.mkOutOfStoreSymlink "/data";
			"Downloads".source =
				config.lib.file.mkOutOfStoreSymlink "/data/Downloads";
		};
	};
}
