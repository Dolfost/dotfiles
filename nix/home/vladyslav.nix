{ pkgs, ... }:

{
	home.packages = with pkgs; [ tree claude-code ];
	programs.zsh.enable = true;

	programs.git = {
		enable = true;
		userName = "Vladyslav Rehan";
		userEmail = "rehanvladyslav@gmail.com";
		aliases = {
			s = "status --short --branch";
			l = "log --oneline --graph --decorate";
		};
		ignores = [ "*~" ".direnv/" ];
		extraConfig = {
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
