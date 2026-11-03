# ssh-chat (https://github.com/shazow/ssh-chat): a chat room anyone on the
# LAN can join with nothing but an ssh client - `ssh -p <port> <nick>@<host>`.
# The ssh username is the nick, the key is the identity, no accounts.
#
# nixpkgs has the package but no service, so this is the service: a hardened
# DynamicUser unit, a server host key generated once into /var/lib/ssh-chat
# (clients pin it on first connect; losing it across rebuilds would greet
# everyone with a "host key changed" scare), the room history in the journal, a
# `lchat [nick]` command that connects with the fleet key so the admin rights
# land on the right identity, a notification per incoming message, and
# optionally a claude bot: "@claude <question>" in the room gets a short answer
# back from Claude Code, posted as nick "claude". Not a slash command: ssh-chat
# has no plugin hook, the server refuses an unknown /command and it never
# reaches the room. The bot is a user service (claude lives in the user profile
# and uses the user's login) following the same journal the notifier does, with
# one ssh session kept open to talk.
#
# Admin keys get /kick /ban /op /mute and friends. An empty whitelist means
# the room is open to whoever can reach the port; fill it to lock the room
# to known keys.
{ config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.ssh-chat;
	user = config.dotfiles.user;
	me = config.networking.hostName;

	stateDir = "/var/lib/ssh-chat";
	hostKey = "${stateDir}/host_key";
	motd = pkgs.writeText "ssh-chat-motd" cfg.motd;
	admins = pkgs.writeText "ssh-chat-admins" (lib.concatLines cfg.admins);
	whitelist = pkgs.writeText "ssh-chat-whitelist" (lib.concatLines cfg.whitelist);

	# Follows the room history in the journal (wheel can read it) and raises a
	# notification per message from anyone but me, unless the overlay
	# (hypr/lchat.lua) is focused. Private messages never enter the room
	# history, so only public ones notify.
	notify = pkgs.writeShellScript "lchat-notify" ''
		${pkgs.systemd}/bin/journalctl -u ssh-chat -f -n 0 -o cat |
		while IFS= read -r line; do
			# Room history lines are "[2026-10-28 09:50:04] <rest>"; the server's
			# own stderr has no such stamp. In <rest>, a message is "nick: text";
			# joins/leaves start with " * " and emotes with "** ".
			[[ $line =~ ^\[[0-9-]+\ [0-9:]+\]\ (.*)$ ]] || continue
			rest=''${BASH_REMATCH[1]}
			[[ $rest =~ ^([^\ :]+):\ (.*)$ ]] || continue
			nick=''${BASH_REMATCH[1]}
			msg=''${BASH_REMATCH[2]}
			[ "$nick" = "${cfg.nick}" ] && continue
			focused=$(${config.programs.hyprland.package}/bin/hyprctl activewindow -j 2>/dev/null |
				${pkgs.jq}/bin/jq -r .class)
			[ "$focused" = lchat ] && continue
			${pkgs.libnotify}/bin/notify-send -a lchat -t 5000 -- "$nick" "$msg"
		done
	'';

	# The claude bot. One ssh session as the bot nick (its own key, generated
	# once into the state dir so the identity survives restarts) is fed through a
	# fifo on fd 3 and its output dropped; the questions come from the journal
	# like the notifier's. The server reads a line up to a carriage return (no
	# pty, the terminal library does the line editing), takes at most 1024 bytes
	# per line and 3 lines per 3 seconds. `claude -c` in the state dir continues
	# the chat's own conversation - nothing else is ever run there.
	bot = pkgs.writeShellScript "lchat-claude" ''
		set -u
		export LC_ALL=C.UTF-8
		export PATH=$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:$PATH
		nick=${cfg.claude.nick}
		state=''${XDG_STATE_HOME:-$HOME/.local/state}/lchat-claude
		mkdir -p "$state" && cd "$state" || exit 1
		[ -f key ] || ${pkgs.openssh}/bin/ssh-keygen -q -t ed25519 -N "" -C lchat-claude -f key

		# The session is a background job on a fifo, the journal loop another:
		# whichever ends first (the chat restarted, journalctl died) ends the
		# script, and systemd brings it back with a fresh session.
		rm -f in && mkfifo -m 600 in
		${pkgs.openssh}/bin/ssh -T -p ${toString cfg.port} -i key \
			-o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new \
			-o UserKnownHostsFile="$state/known_hosts" -o ServerAliveInterval=30 \
			-o LogLevel=ERROR "$nick@localhost" <in >/dev/null &
		exec 3>in

		say() { printf "%s\r\n" "$1" >&3 || exit 1; }

		answer() {
			local who=$1 question=$2 reply first=1 line
			reply=$(printf "%s: %s" "$who" "$question" |
				claude -p -c --append-system-prompt ${lib.escapeShellArg cfg.claude.prompt} \
					${lib.escapeShellArgs (lib.optionals cfg.claude.web [ "--allowedTools" "WebSearch" "WebFetch" ] ++ cfg.claude.extraArgs)}) ||
				reply="claude failed, see journalctl --user -u lchat-claude"
			# Said "nick: text" is the input format, it answers "nick: text" too.
			[[ $reply =~ ^(@?"$who"[,:]?[[:space:]]+)+(.*)$ ]] && reply=''${BASH_REMATCH[2]}
			reply=''${reply:0:1024}
			# Folded by characters: a line must stay under 1024 bytes and
			# cyrillic is two bytes a letter.
			printf "%s\n" "$reply" | ${pkgs.coreutils}/bin/fold -s -w 480 |
			while IFS= read -r line; do
				line=''${line%"''${line##*[![:space:]]}"} # fold leaves the trailing blank
				[ -z "$line" ] && continue
				if [ "$first" = 1 ]; then
					line="@$who $line"
					first=0
				else
					${pkgs.coreutils}/bin/sleep 1.1
				fi
				case $line in /*) line=" $line" ;; esac # never a command
				say "$line"
			done
		}

		${pkgs.systemd}/bin/journalctl -u ssh-chat -f -n 0 -o cat |
		while IFS= read -r line; do
			[[ $line =~ ^\[[0-9-]+\ [0-9:]+\]\ ([^\ :]+):\ (.*)$ ]] || continue
			from=''${BASH_REMATCH[1]}
			msg=''${BASH_REMATCH[2]}
			[ "$from" = "$nick" ] && continue
			[[ $msg =~ ^@"$nick"[,:]?[[:space:]]+(.+)$ ]] || continue
			answer "$from" "''${BASH_REMATCH[1]}"
		done &

		wait -n
		exit 1
	'';
in
{
	options.dotfiles.ssh-chat = {
		port = lib.mkOption {
			type = lib.types.port;
			default = 14159;
			description = "TCP port the chat listens on, on every interface.";
		};
		admins = lib.mkOption {
			type = lib.types.listOf lib.types.str;
			default = [ ];
			description = "Public keys (authorized_keys lines) that join as room operators.";
		};
		whitelist = lib.mkOption {
			type = lib.types.listOf lib.types.str;
			default = [ ];
			description = "If non-empty, only these public keys may connect.";
		};
		nick = lib.mkOption {
			type = lib.types.str;
			default = "vlad";
			description = "Nick `lchat` joins with when given none; its messages don't notify.";
		};
		claude = {
			enable = lib.mkEnableOption "the claude bot: `@claude <question>` in the room";
			nick = lib.mkOption {
				type = lib.types.str;
				default = "claude";
				description = "Nick the bot joins as; `@<nick>` at the start of a message asks it.";
			};
			prompt = lib.mkOption {
				type = lib.types.str;
				default = lib.concatStringsSep " " ([
					"You are answering inside a small plain-text chat room over SSH on a home LAN."
					"Several people read it and every message is one line, so reply in plain text only:"
					"no markdown, no headings, no bullet points, no code fences."
					"Keep it short: one to three sentences, never more than 1024 characters."
					"Answer in the language of the question."
					"Each message arrives as \"nick: text\" so you know who is asking;"
					"reply with the answer alone, never prefixed with a nick or \"nick:\"."
				] ++ lib.optional cfg.claude.web
					"Search the web when the question needs current facts (weather, news, prices)."
				);
				description = "Appended to the system prompt: the chat context and the length limit.";
			};
			web = lib.mkEnableOption "web access for the bot (WebSearch and WebFetch) and a prompt line saying so";
			extraArgs = lib.mkOption {
				type = lib.types.listOf lib.types.str;
				default = [ ];
				example = [ "--allowedTools" "WebSearch" "--model" "haiku" ];
				description = "Extra `claude -p` arguments.";
			};
		};
		motd = lib.mkOption {
			type = lib.types.lines;
			# A list, not an indented string: Nix only strips leading spaces from
			# '' strings and this file is tab-indented.
			default = lib.concatLines ([
				"  === ${me} chat ===  nothing here leaves the LAN"
				""
				"  /nick <name>        change your name"
				"  /msg <nick> <text>  private message"
				"  /theme mono|colors|hacker"
				"  /names              who is here"
				"  /whois <nick>       their key fingerprint"
				"  /help               the rest"
			] ++ lib.optional cfg.claude.enable
				"  @${cfg.claude.nick} <question>  ask claude, it answers in the room, briefly"
			++ [
				""
				"  Rejoin with the same key to keep your identity."
			]);
			description = "Message of the day, shown on join.";
		};
		openFirewall = lib.mkOption {
			type = lib.types.bool;
			default = true;
			description = "Open the port in the firewall.";
		};
	};

	config = {
		systemd.services.ssh-chat = {
			description = "Chat over SSH";
			wantedBy = [ "multi-user.target" ];
			after = [ "network.target" ];

			# openssl, not ssh-keygen: ssh-keygen fatals on getpwuid() and the
			# DynamicUser uid has no passwd entry inside the sandbox. ssh-chat
			# reads the PKCS#8 PEM openssl writes.
			preStart = ''
				if [ ! -f ${hostKey} ]; then
					${pkgs.openssl}/bin/openssl genpkey -algorithm ed25519 -out ${hostKey}
					chmod 600 ${hostKey}
				fi
			'';

			serviceConfig = {
				ExecStart = lib.concatStringsSep " " ([
					(lib.getExe pkgs.ssh-chat)
					"--bind 0.0.0.0:${toString cfg.port}"
					"--identity ${hostKey}"
					"--motd ${motd}"
					# Room history to stdout, i.e. the journal. A file would land
					# under /var/log/private (DynamicUser), unreadable for the
					# notifier.
					"--log -"
					"--verbose"
				]
				++ lib.optional (cfg.admins != [ ]) "--admin ${admins}"
				++ lib.optional (cfg.whitelist != [ ]) "--whitelist ${whitelist}");
				Restart = "on-failure";
				RestartSec = 2;

				DynamicUser = true;
				StateDirectory = "ssh-chat";
				StateDirectoryMode = "0700";

				NoNewPrivileges = true;
				PrivateTmp = true;
				PrivateDevices = true;
				ProtectHome = true;
				ProtectSystem = "strict";
				ProtectKernelTunables = true;
				ProtectKernelModules = true;
				ProtectControlGroups = true;
				ProtectClock = true;
				ProtectHostname = true;
				RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
				RestrictNamespaces = true;
				RestrictRealtime = true;
				LockPersonality = true;
				MemoryDenyWriteExecute = true;
				SystemCallArchitectures = "native";
				SystemCallFilter = [ "@system-service" "~@privileged" ];
				CapabilityBoundingSet = "";
				AmbientCapabilities = "";
			};
		};

		networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

		# `lchat [nick]` from this machine. IdentitiesOnly matters: ssh-chat takes
		# the first key the client offers, and only the fleet key is an admin.
		environment.systemPackages = [
			(pkgs.writeShellScriptBin "lchat" ''
				exec ssh -p ${toString cfg.port} -i ~/.ssh/home -o IdentitiesOnly=yes \
					"''${1:-${cfg.nick}}@localhost"
			'')
		];

		home-manager.users.${user}.systemd.user.services = {
			lchat-notify = lib.mkIf config.dotfiles.graphical {
				Unit = {
					Description = "Notifications for new LAN chat messages";
					After = [ "graphical-session.target" ];
					PartOf = [ "graphical-session.target" ];
				};
				Service = {
					ExecStart = "${notify}";
					Restart = "on-failure";
					RestartSec = 5;
				};
				Install.WantedBy = [ "graphical-session.target" ];
			};

			lchat-claude = lib.mkIf cfg.claude.enable {
				Unit = {
					Description = "Claude bot in the LAN chat";
					After = [ "network.target" ];
				};
				Service = {
					ExecStart = "${bot}";
					# Exits when the session drops (the chat restarted); back in 5 s.
					Restart = "always";
					RestartSec = 5;
				};
				Install.WantedBy = [ "default.target" ];
			};
		};
	};
}
