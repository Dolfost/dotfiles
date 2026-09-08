# Viewers, players, and the tools that feed them. The CLI tools are
# useful everywhere, headless included — only the viewers are gated.
{ config, lib, pkgs, ... }:

let
	link = config.lib.dotfiles.link;
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
				gimp
			];

			xdg.configFile."zathura" = link "zathura";

			# Default handlers (~/.config/mimeapps.list): mpv for video, nomacs for
			# images, zathura for documents, nvim for text.
			xdg.mimeApps = {
				enable = true;
				defaultApplications =
					let
						assign = app: types: lib.genAttrs types (_: app);
					in
					assign "mpv.desktop" [
						"video/mp4"
						"video/x-matroska"
						"video/webm"
						"video/mpeg"
						"video/x-msvideo"
						"video/quicktime"
						"video/x-flv"
						"video/x-ms-wmv"
						"video/ogg"
					]
					// assign "org.nomacs.ImageLounge.desktop" [
						"image/jpeg"
						"image/png"
						"image/gif"
						"image/webp"
						"image/bmp"
						"image/tiff"
						"image/svg+xml"
						"image/avif"
						"image/heif"
					]
					// assign "org.pwmt.zathura.desktop" [
						"application/pdf"
						"application/epub+zip"
					]
					// assign "nvim.desktop" [
						"text/plain"
						"text/markdown"
					]
					# carried over from the previously unmanaged mimeapps.list
					// assign "org.telegram.desktop.desktop" [
						"x-scheme-handler/tg"
						"x-scheme-handler/tonsite"
					]
					// assign "claude-code-url-handler.desktop" [
						"x-scheme-handler/claude-cli"
					];
			};
		})
	];
}
