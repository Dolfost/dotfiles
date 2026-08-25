# The one human account these machines are built around.
#
# Exists so nothing under modules/ has to name it. The contract: each module
# under modules/ carries a feature's system half and, via
# home-manager.users.${dotfiles.user}, its home half from nix/home/ — so hosts/
# only ever picks modules (plus hardware facts), and modules never hardcode a
# login name.
{ lib, ... }:

{
	options.dotfiles.user = lib.mkOption {
		type = lib.types.str;
		default = "vladyslav";
		description = "Login name of the primary account.";
	};
}
