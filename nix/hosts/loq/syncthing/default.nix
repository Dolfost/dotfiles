# Folders this laptop carries; aorus owns the canonical copies on /storage.
{ ... }:

{
	imports = [ ../../../modules/system/syncthing ];

	dotfiles.syncthing.folders = {
		books = "/home/vladyslav/data/books";
		obsidian = "/home/vladyslav/data/obsidian";
		avatars = "/home/vladyslav/data/avatars";
	};
}
