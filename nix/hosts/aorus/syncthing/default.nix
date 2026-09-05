# This box owns every share; the big ones live on /storage, the phone drop-box
# in $HOME.
{ ... }:

{
	imports = [ ../../../modules/system/syncthing ];

	dotfiles.syncthing.folders = {
		books = "/storage/2.5/media/books";
		obsidian = "/storage/data/obsidian";
		shared = "/home/vladyslav/data/shared";
	};
}
