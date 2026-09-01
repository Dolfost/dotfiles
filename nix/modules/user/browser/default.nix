{ config, lib, pkgs, ... }:

{
	options.dotfiles.browser.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Web browser.";
	};

	config = lib.mkIf config.dotfiles.browser.enable {
		home.packages = [ pkgs.firefox ];
	};
}
