{ config, ... }: {
	home-manager.users.${config.dotfiles.user}.dotfiles.openrgb = {
		dir = "nix/hosts/aorus/openrgb/OpenRGB";
		profile = "OFF";
	};
}
