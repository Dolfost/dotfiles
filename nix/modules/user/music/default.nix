# Music library tagging and QC. The CLI tools are useful headless too - only
# the GUI apps are gated. Picard already wraps chromaprint, so AcoustID
# fingerprinting works without a separate fpcalc install.
{ config, lib, pkgs, ... }:

{
	options.dotfiles.music.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Music tagging tools.";
	};

	config = lib.mkMerge [
		{
			home.packages = with pkgs; [
				rsgain
				flac
			];
		}

		(lib.mkIf config.dotfiles.music.enable {
			home.packages = with pkgs; [
				picard
				lrcget
				sonic-visualiser
			];
		})
	];
}
