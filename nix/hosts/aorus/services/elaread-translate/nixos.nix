# The relay as a NixOS module, for a NixOS host other than evictus:
#
#   imports = [ ./elaread-translate/nixos.nix ];
#   services.elaread-translate.enable = true;
#   services.elaread-translate.user = "alice";   # whose Claude Code login to use
#   nixpkgs.config.allowUnfreePredicate = p: builtins.elem (lib.getName p) [ "claude-code" ];
#
# With `user` the relay runs as that user and uses their ~/.claude. Without it, it
# runs as a throwaway user and the login is a token in /etc/elaread-translate.env
# (chmod 600): CLAUDE_CODE_OAUTH_TOKEN=..., from `claude setup-token`. See README.md.
{ config, lib, pkgs, ... }:

let
	cfg = config.services.elaread-translate;
	own = cfg.user != null;
	home = if own then config.users.users.${cfg.user}.home else "/var/lib/elaread-translate";
in
{
	options.services.elaread-translate = {
		enable = lib.mkEnableOption "the Elaread translation relay";
		listen = lib.mkOption {
			type = lib.types.str;
			default = "100.91.220.75:8787";
			description = "This host's tailnet address and port.";
		};
		allow = lib.mkOption {
			type = lib.types.listOf lib.types.str;
			default = [ "127.0.0.1" "100.67.0.1" "100.67.0.2" "100.67.0.3" ];
			description = "Addresses that get an answer: the app owner's own tailnet nodes.";
		};
		parallel = lib.mkOption {
			type = lib.types.ints.positive;
			default = 4;
			description = "claude processes at once.";
		};
		package = lib.mkOption {
			type = lib.types.package;
			default = pkgs.claude-code;
			defaultText = lib.literalExpression "pkgs.claude-code";
			description = "The Claude Code to run; ideally the one `user` is logged in with.";
		};
		user = lib.mkOption {
			type = lib.types.nullOr lib.types.str;
			default = null;
			example = "alice";
			description = "A user already logged in to Claude Code; null runs a throwaway user with a token instead.";
		};
		openFirewall = lib.mkOption {
			type = lib.types.bool;
			default = true;
			description = "Open the port on tailscale0 only.";
		};
		environmentFile = lib.mkOption {
			type = lib.types.str;
			default = "/etc/elaread-translate.env";
			description = "Optional; holds CLAUDE_CODE_OAUTH_TOKEN, kept out of the Nix store.";
		};
	};

	config = lib.mkIf cfg.enable {
		networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkIf cfg.openFirewall [
			(lib.toInt (lib.last (lib.splitString ":" cfg.listen)))
		];

		systemd.services.elaread-translate = {
			description = "Elaread translation relay to claude -p";
			wantedBy = [ "multi-user.target" ];
			# The tailnet address exists once tailscaled is up; until then Restart= tries again.
			wants = [ "network-online.target" ];
			after = [ "network-online.target" "tailscaled.service" ];
			environment = {
				ELAREAD_CLAUDE = "${cfg.package}/bin/claude";
				ELAREAD_LISTEN = cfg.listen;
				ELAREAD_ALLOW = lib.concatStringsSep "," cfg.allow;
				ELAREAD_PARALLEL = toString cfg.parallel;
				HOME = home;
				DISABLE_AUTOUPDATER = "1";
			};
			serviceConfig = {
				ExecStart = "${pkgs.python3}/bin/python3 -I ${./elaread-translate.py}";
				# "-": no file is fine when `user` brings the login.
				EnvironmentFile = "-${cfg.environmentFile}";
				Restart = "always";
				RestartSec = 10;
				# An empty working dir: no project CLAUDE.md for claude to pick up.
				StateDirectory = "elaread-translate";
				WorkingDirectory = "/var/lib/elaread-translate";
				NoNewPrivileges = true;
				ProtectSystem = "strict";
				ProtectHome = !own;
				# claude rewrites ~/.claude.json and its credentials in place.
				ReadWritePaths = lib.optional own home;
				PrivateTmp = true;
				PrivateDevices = true;
				ProtectKernelTunables = true;
				ProtectKernelModules = true;
				ProtectKernelLogs = true;
				ProtectControlGroups = true;
				ProtectClock = true;
				ProtectHostname = true;
				RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
				RestrictNamespaces = true;
				RestrictRealtime = true;
				LockPersonality = true;
				SystemCallArchitectures = "native";
				MemoryMax = "3G";
				TasksMax = 512;
			} // (if own then { User = cfg.user; } else { DynamicUser = true; });
		};
	};
}
