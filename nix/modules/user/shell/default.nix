# Shell and editor config links. Always on - every account that gets a home
# gets a shell.
{ config, pkgs, ... }:

let
	link = config.lib.dotfiles.link;
	# nvim-treesitter with every grammar and its queries from nixpkgs, flattened
	# into one plugin dir (lua/, parser/*.so, queries/*). lazy.nvim uses it as
	# the plugin when the link exists - see nvim/lua/plugins/treesitter.lua.
	treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
	treesitterPack = pkgs.symlinkJoin {
		name = "nvim-treesitter-with-grammars";
		paths = [ treesitter ] ++ treesitter.dependencies;
	};
in
{
	# The zsh config loads sheldon, so it travels with the links.
	home.packages = with pkgs; [
		sheldon zellij neovim
	];

	programs.direnv = {
		enable = true;
		nix-direnv.enable = true;
	};

	home.file = {
		".zshrc" = link "zsh/zshrc";
		".zprofile" = link "zsh/zprofile";
		".tmux.conf" = link "tmux/tmux.conf";
		".tmate.conf" = link "tmux/tmate.conf";
	};

	xdg.dataFile."nvim/nix/nvim-treesitter".source = treesitterPack;

	xdg.configFile = {
		"zsh" = link "zsh/zsh";
		"sheldon" = link "zsh/sheldon";
		"nvim" = link "nvim";
		"zellij" = link "zellij";
	};
}
