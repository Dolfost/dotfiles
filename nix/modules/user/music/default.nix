# Music library tagging and QC. Picard already wraps chromaprint, so
# AcoustID fingerprinting works without a separate fpcalc install.
{ config, lib, pkgs, ... }:

{
	options.dotfiles.music.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Music tagging tools.";
	};

	config = lib.mkIf config.dotfiles.music.enable {
		home.packages = with pkgs; [
			picard
			rsgain
			lrcget
			flac
			spek
		];
	};
}
