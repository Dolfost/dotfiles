# Services the phone hosts for the network, one file each.
{ ... }:

{
	imports = [
		./pihole.nix
		./ntfy.nix
	];
}
