{ config, lib, pkgs, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink
			"${config.home.homeDirectory}/dotfiles/${path}";
	};

	apps = { inherit (pkgs) waybar fuzzel dunst wezterm zathura; };
in {
	home.packages = lib.attrValues apps;

	xdg.configFile = lib.mapAttrs (name: _: link name) apps // {
		"hypr" = link "hypr";
	};
}
