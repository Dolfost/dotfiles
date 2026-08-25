{ config, pkgs, ... }:

let
	dotfiles = "${config.home.homeDirectory}/dotfiles";

	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
	};
in {
	# The zsh config loads sheldon, so it travels with the links.
	home.packages = [ pkgs.sheldon ];

	home.file = {
		".zshrc" = link "zsh/zshrc";
		".zprofile" = link "zsh/zprofile";
		".tmux.conf" = link "tmux/tmux.conf";
		".tmate.conf" = link "tmux/tmate.conf";
	};

	xdg.configFile = {
		"zsh" = link "zsh/zsh";
		"sheldon" = link "zsh/sheldon";
		"nvim" = link "nvim";
	};
}
