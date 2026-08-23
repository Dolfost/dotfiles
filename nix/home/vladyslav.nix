{ config, pkgs, ... }:

let
	dotfiles = "${config.home.homeDirectory}/dotfiles";

	link = path: {
		source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
	};
in {
	home.packages = with pkgs; [
		tree claude-code sheldon
		gnumake cmake
		lua-language-server
		clang zathura
	];

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
		"hypr" = link "hypr";
		"zathura" = link "zathura";
	};

	programs.git = {
		enable = true;
		ignores = [ "*~" ".direnv/" ];
		settings = {
			user.name = "Vladyslav Rehan";
			user.email = "rehanvladyslav@gmail.com";
			alias = {
				s = "status --short --branch";
				l = "log --oneline --graph --decorate";
			};
			init.defaultBranch = "main";
			push.autoSetupRemote = true;
			pull.rebase = true;
			rebase.autoStash = true;
			diff.algorithm = "histogram";
			core.editor = "nvim";
		};
	};

	home.stateVersion = "26.05"; # DO NOT CHANGE
}
