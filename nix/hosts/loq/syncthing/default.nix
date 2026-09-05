# Folders this laptop carries; aorus owns the canonical copies on /storage.
{ ... }:

{
	imports = [ ../../../modules/system/syncthing ];

	dotfiles.syncthing.folders = {
		books = "/home/vladyslav/books";
		obsidian = "/home/vladyslav/obsidian";
	};
}
