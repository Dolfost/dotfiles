# The phone is the always-on peer for the small folders, so a change made
# anywhere lands somewhere even when the desktops are off. Its identity was
# generated on the device (facts.nix has the id), not in sops.
{ ... }:

{
	imports = [ ../../../modules/system/syncthing ];
	dotfiles.syncthing.identityFromSops = false;
	dotfiles.syncthing.folders = {
		obsidian = "/home/vladyslav/data/obsidian";
		shared   = "/home/vladyslav/data/shared";
		avatars  = "/home/vladyslav/data/avatars";
	};
}
