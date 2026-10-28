# ssh-chat (https://github.com/shazow/ssh-chat): a chat room anyone on the LAN
# can join with nothing but an ssh client - `ssh -p <port> <nick>@<host>`. The
# ssh username is the nick, the key is the identity, no accounts.
#
# nixpkgs has the package but no service, so this is the service: a hardened
# DynamicUser unit, a server host key generated once into /var/lib/ssh-chat
# (clients pin it on first connect; losing it across rebuilds would greet
# everyone with a "host key changed" scare), a chat log under /var/log, and a
# `lchat [nick]` command that connects with the fleet key so the admin rights
# land on the right identity.
#
# Admin keys get /kick /ban /op /mute and friends. An empty whitelist means the
# room is open to whoever can reach the port; fill it to lock the room to known
# keys.
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
			description = "Nick `lchat` joins with when given none.";
		};
		motd = lib.mkOption {
			type = lib.types.lines;
# A list, not an indented string: Nix only strips leading spaces from
# '' strings and this file is tab-indented.
			default = lib.concatLines [
				"  === ${me} chat ===  nothing here leaves the LAN"
					""
					"  /nick <name>        change your name"
					"  /msg <nick> <text>  private message"
					"  /theme mono|colors|hacker"
					"  /names              who is here"
					"  /whois <nick>       their key fingerprint"
					"  /help               the rest"
					""
					"  Rejoin with the same key to keep your identity."
			];
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
						"--log /var/log/ssh-chat/chat.log"
						"--verbose"
				]
				++ lib.optional (cfg.admins != [ ]) "--admin ${admins}"
				++ lib.optional (cfg.whitelist != [ ]) "--whitelist ${whitelist}");
				Restart = "on-failure";
				RestartSec = 2;

				DynamicUser = true;
				StateDirectory = "ssh-chat";
				StateDirectoryMode = "0700";
				LogsDirectory = "ssh-chat";

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

# `lchat [nick]` from this machine. IdentitiesOnly matters: ssh-chat takes the
# first key the client offers, and only the fleet key is an admin.
		environment.systemPackages = [
			(pkgs.writeShellScriptBin "lchat" ''
			 exec ssh -p ${toString cfg.port} -i ~/.ssh/home -o IdentitiesOnly=yes \
			 "''${1:-${cfg.nick}}@localhost"
			 '')
		];
	};
}
