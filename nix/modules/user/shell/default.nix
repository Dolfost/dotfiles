# Shell and editor config links. Always on — every account that gets a
# home gets a shell.
{ config, pkgs, ... }:

let
	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.dir}/${path}";
	};
in
{
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
