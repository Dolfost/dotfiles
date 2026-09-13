# Viewers, players, and the tools that feed them. The CLI tools are
# useful everywhere, headless included — only the viewers are gated.
{ osConfig ? { }, config, lib, pkgs, ... }:

let
	link = config.lib.dotfiles.link;
in
{
	options.dotfiles.media.enable = lib.mkOption {
		type = lib.types.bool;
		default = config.dotfiles.graphical;
		description = "Media viewers and players.";
	};

	options.dotfiles.media.recordDir = lib.mkOption {
		type = lib.types.str;
		default =
			let host = (osConfig.dotfiles.media or { }).recordDir or null;
			in if host == null then "${config.home.homeDirectory}/Videos" else host;
		description = "Where OBS saves recordings. Follows the host's dotfiles.media.recordDir on NixOS.";
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
				drawio
				freecad
				# Screen capture works through the PipeWire portal out of the box; the
				# plugins add per-application audio capture and Vulkan/GL game capture
				# (run the game with `obs-gamecapture` or OBS_VKCAPTURE=1).
				(wrapOBS {
					plugins = with obs-studio-plugins; [
						obs-pipewire-audio-capture
						obs-vkcapture
					];
				})
			];

			xdg.configFile."zathura" = link "zathura";

			# OBS rewrites its ini wholesale on every settings change, so (like the
			# GSR config in ../gaming) it stays mutable and nix re-pins just the
			# save locations on each switch, in every profile that exists by then.
			# Each substitution is scoped to its ini section so a same-named key
			# appearing elsewhere someday can't be clobbered.
			home.activation.obsRecordDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
				run mkdir -p "${config.dotfiles.media.recordDir}"
				for ini in ${config.xdg.configHome}/obs-studio/basic/profiles/*/basic.ini; do
					[ -e "$ini" ] || continue
					run ${pkgs.gnused}/bin/sed -i \
						-e '/^\[SimpleOutput\]/,/^\[/ s|^FilePath=.*|FilePath=${config.dotfiles.media.recordDir}|' \
						-e '/^\[AdvOut\]/,/^\[/ s|^RecFilePath=.*|RecFilePath=${config.dotfiles.media.recordDir}|' \
						-e '/^\[AdvOut\]/,/^\[/ s|^FFFilePath=.*|FFFilePath=${config.dotfiles.media.recordDir}|' \
						"$ini"
				done
			'';

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
