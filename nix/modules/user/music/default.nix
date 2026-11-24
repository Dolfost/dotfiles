# Music library tagging and QC. The CLI tools are useful headless too - only
# the GUI apps are gated. Picard already wraps chromaprint, so AcoustID
# fingerprinting works without a separate fpcalc install.
#
# The commands below are what Claude Code's music skill (claude/skills/music)
# drives to take an album from Soulseek into the library:
#   slsk         search and download through the running Nicotine+ (./slsk.py,
#                the client of containers/nicotine/plugins/agent_api)
#   flac-verify  integrity, lossy transcodes, upsampling, padded bit depth
#   music-tag    MusicBrainz tags and the cover, headless, via beets
#   mlib         strip pictures, resample, name and move into the library,
#                lyrics, artist picture, a cover picked by hand
# They are plain files next to this one; here each gets an interpreter and
# its tools. The paths they default to are aorus' (the host with the
# library and the nicotine container); elsewhere they are just inert.
{ config, lib, pkgs, ... }:

let
	# doCheck: the writer would otherwise run flake8 over them at build time.
	python = name: libraries: pkgs.writers.writePython3Bin name {
		inherit libraries;
		doCheck = false;
	} (builtins.readFile (./. + "/${name}.py"));

	slsk = python "slsk" [ ];
	flac-verify = python "flac-verify" [ pkgs.python3Packages.numpy ];
	mlib = python "mlib" [ ];

	music-tag = pkgs.writeShellApplication {
		name = "music-tag";
		runtimeInputs = with pkgs; [ beets flac coreutils findutils gnugrep mlib ];
		runtimeEnv.BEETS_CONFIG = "${./beets.yaml}";
		text = builtins.readFile ./music-tag.sh;
	};
in
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
				sox
				ffmpeg

				slsk
				flac-verify
				music-tag
				mlib
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
