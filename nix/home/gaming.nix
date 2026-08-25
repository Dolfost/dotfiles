{ config, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink
			"${config.home.homeDirectory}/dotfiles/${path}";
	};
in {
	xdg.configFile."MangoHud" = link "MangoHud";
}
