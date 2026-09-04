{ config, ... }: {
	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	# Lets plain `nixos-rebuild switch` find the flake: it defaults to
	# /etc/nixos/flake.nix#<hostname> when that file exists. The source is a
	# string on purpose - a path literal would be copied into the store, a string
	# stays a symlink to the live checkout.
	environment.etc."nixos/flake.nix".source =
		"${config.users.users.${config.dotfiles.user}.home}/dotfiles/flake.nix";
}
