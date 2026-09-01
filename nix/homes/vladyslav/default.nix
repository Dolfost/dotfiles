{ pkgs, ... }:

{
	imports = [ ../../modules/user ];

	home.username = "vladyslav";
	home.homeDirectory = "/home/vladyslav";

	home.packages = with pkgs; [
		tree claude-code
		gnumake cmake
		lua-language-server
		clang
	];

	systemd.user.services.tmux = {
		Unit.Description = "tmux session";
		Service = {
			Type = "oneshot";
			RemainAfterExit = true;
			ExecStart = pkgs.writeShellScript "tmux-main" ''
				${pkgs.tmux}/bin/tmux has-session -t main 2>/dev/null \
					|| ${pkgs.tmux}/bin/tmux new-session -d -s main
			'';
			ExecStop = "${pkgs.tmux}/bin/tmux kill-session -t main";
			KillMode = "none";
		};
		Install.WantedBy = [ "default.target" ];
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
