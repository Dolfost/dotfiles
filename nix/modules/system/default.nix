# Baseline every host imports. Features (./desktop, ./gaming) are picked
# per host.
{ config, lib, pkgs, inputs, ... }:

{
	imports = [
		./dotfiles
		./boot
		./locale
		./audio
		./bluetooth
		./network
		./nix
		./input
		./user
		./kernel
		./sops
	];
	config = {
		environment.systemPackages = with pkgs; [
			# nodejs: nvim's pandoc-preview plugin serves via `npx browser-sync`
			neovim nodejs tree ripgrep wget git git-lfs tmux btop sops age ssh-to-age
			gnutar zip unzip unrar p7zip
		];
		home-manager = {
			useGlobalPkgs = true;
			useUserPackages = false;
			extraSpecialArgs = { inherit inputs; };
			startAsUserService = true;
			backupFileExtension = "hm-bak";
			# One entry point per user, shared with the standalone flake output. The
			# desktop/gaming home halves gate themselves on osConfig, so hosts only
			# ever pick system features.
			users.${config.dotfiles.user} = {
				imports = [ (../../homes + "/${config.dotfiles.user}") ];
				# The home speaks the same dotfiles vocabulary but can't see the
				# host's DE; hand it the answers so the GUI groups follow along.
				dotfiles.graphical = lib.mkDefault config.dotfiles.graphical;
				dotfiles.dir = lib.mkDefault config.dotfiles.dir;
			};
		};
	};
}
