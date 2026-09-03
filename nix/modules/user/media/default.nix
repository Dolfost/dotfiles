# Viewers, players, and the tools that feed them. The CLI tools are
# useful everywhere, headless included — only the viewers are gated.
{ config, lib, pkgs, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};
in
{
	options.dotfiles.media.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Media viewers and players.";
	};

	config = lib.mkMerge [
		{
			home.packages = with pkgs; [
				imagemagick
				ffmpeg
				yt-dlp
			];
		}

		(lib.mkIf config.dotfiles.media.enable {
			home.packages = with pkgs; [
				nomacs
				mpv
				zathura
				feishin
			];

			xdg.configFile."zathura" = link "zathura";
		})
	];
}
