# ~/.ssh/config generated from the fleet facts (../../../facts.nix).
# Canonicalization tries <name>.<ts_network> first, so a bare `ssh dloq`
# resolves through the tailnet on every machine; if that fails it falls back to
# the local resolver. Blocks that overlap the *.wg / *.ts.net catch-all are
# dag-ordered before it so their user/port win.
#
# Only network-wide hosts live here; each machine adds its own extras
# from nix/hosts/<name>/ssh.nix (the settings attrsets merge).
{ osConfig ? { }, lib, ... }:

let
	facts = import ../../../facts.nix;
	net = facts.ts_network;
	home_key = "~/.ssh/home";
	me = osConfig.networking.hostName or null;

	catch_all = "*.wg *.${net}";
	before_catch_all = lib.hm.dag.entryBefore [ catch_all ];

	phones = lib.filterAttrs (_: machine: machine ? port) facts.hosts;
	phone_blocks = lib.mapAttrs' (name: machine:
		let d = machine.ts_hostname; in
		lib.nameValuePair "${d} ${d}.wg ${d}.${net}" (before_catch_all {
			User = machine.user;
			Port = machine.port;
		})) phones;

	# LAN fallbacks for when the tailnet is not up: the bare machine name hits
	# the wired address, <name>w the wifi one. Only the other machines - no host
	# needs a block for itself.
	lan_block = address: {
		HostName = address;
		User = "vladyslav";
		IdentityFile = home_key;
	};
	lan_blocks = lib.concatMapAttrs (name: machine:
		lib.optionalAttrs (name != me) (
			lib.optionalAttrs (machine ? lan_ipv4) { ${name} = lan_block machine.lan_ipv4; }
			// lib.optionalAttrs (machine ? lan_wifi_ipv4) { "${name}w" = lan_block machine.lan_wifi_ipv4; }))
		facts.hosts;
in
{
	programs.ssh = {
		enable = true;
		enableDefaultConfig = false;

		extraOptionOverrides = {
			CanonicalizeHostname = "yes";
			CanonicalDomains = net;
			CanonicalizeMaxDots = "0";
			CanonicalizeFallbackLocal = "yes";
		};

		settings = phone_blocks // lan_blocks // {
			${catch_all} = {
				User = "vladyslav";
				IdentityFile = home_key;
			};

			"github.com" = {
				User = "git";
				IdentityFile = "~/.ssh/git";
			};
			"gitea" = {
				User = "git";
				IdentityFile = "~/.ssh/gitea";
				IdentitiesOnly = "yes";
			};

			# job, but wanted from every machine
			"jet2" = {
				HostName = "192.168.144.67";
				User = "jetson";
				IdentityFile = "~/.ssh/lab35-ml";
			};
		};
	};
}
