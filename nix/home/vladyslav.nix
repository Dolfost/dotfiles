{ config, pkgs, ... }:

let
	dotfiles = "${config.home.homeDirectory}/dotfiles";
in {
	home.packages = with pkgs; [ 
		tree claude-code sheldon 
		gnumake cmake
		lua-language-server
		clang
	];

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
		"nvim".source =
			config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";

		# Outer dir, not hypr/hypr: hyprland.lua refers to
		# ~/.config/hypr/hypr/scripts/. Out-of-store so the gitignored
		# *.local.lua overrides that load_local_config() reads still resolve.
		"hypr".source =
			config.lib.file.mkOutOfStoreSymlink "${dotfiles}/hypr";
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
