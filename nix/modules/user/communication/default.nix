{ config, lib, pkgs, ... }:

{
	options.dotfiles.communication.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Messengers.";
	};

	config = lib.mkIf config.dotfiles.communication.enable {
		home.packages = with pkgs; [
			telegram-desktop
			discord
			signal-desktop
			element-desktop
			viber
		];
	};
}
