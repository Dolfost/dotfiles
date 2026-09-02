# This machine's GPU tuning, carried over from the Arch install.
{ config, ... }:

{
	environment.etc."lact/config.yaml".source =
		"${config.users.users.${config.dotfiles.user}.home}/dotfiles/nix/hosts/aorus/lact/config.yaml";
}
