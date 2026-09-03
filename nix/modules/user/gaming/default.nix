# Overlay config for games.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};
in
{
	options.dotfiles.gaming.enable = lib.mkOption {
		type = lib.types.bool;
		default = osConfig.programs.steam.enable or false;
		description = "Gaming config links. Follows the host's Steam on NixOS.";
	};

	config = lib.mkIf config.dotfiles.gaming.enable {
		home.packages = [ pkgs.protonplus ];
		xdg.configFile."MangoHud" = link "MangoHud";
		home.file.".local/bin/gscope" = link "bin/gscope";
	};
}
