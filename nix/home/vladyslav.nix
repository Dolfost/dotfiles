{ config, pkgs, ... }:

let
	dotfiles = "${config.home.homeDirectory}/dotfiles";
in {
	home.packages = with pkgs; [ tree claude-code sheldon ];

	# Deliberately no `programs.zsh.enable` here - it generates its own ~/.zshrc
	home.file = {
		".zshrc".source =
			config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zsh/zshrc";
		".zprofile".source =
			config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zsh/zprofile";
	};

	xdg.configFile = {
		"zsh".source =
			config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zsh/zsh";
		"sheldon".source =
			config.lib.file.mkOutOfStoreSymlink "${dotfiles}/zsh/sheldon";

		# Must be out-of-store: lazy.nvim writes lazy-lock.json back into its
		# own config dir, which a read-only store copy would break.
		"nvim".source =
			config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";
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
