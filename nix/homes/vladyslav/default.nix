{ pkgs, config, inputs, ... }:

let
	unstable = import inputs.nixpkgs-unstable {
		system = pkgs.stdenv.hostPlatform.system;
		config.allowUnfree = true;
	};
in
{
	imports = [ ../../modules/user ];

	home.username = "vladyslav";
	home.homeDirectory = "/home/${config.home.username}";

	home.packages = with pkgs; [
		unstable.claude-code tree
		lua-language-server
	];

	programs.git = {
		enable = true;
		package = pkgs.git.override { withLibsecret = true; };
		ignores = [ "*~" ".direnv/" ];
		settings = {
			credential.helper = "libsecret";
			user.name = "Vladyslav Rehan";
			user.email = "rehanvladyslav@gmail.com";
			alias = {
				s = "status --short --branch";
				l = "log --oneline --graph --decorate";
				d = "diff";
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
