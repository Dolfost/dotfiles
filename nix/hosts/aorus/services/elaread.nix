# Elaread: translation relay for the Elaread Android reader (web novels). The
# phone posts a chapter's paragraphs to :8787 on the tailnet, the relay runs
# `claude -p` on this box's subscription and returns the translation; aorus is
# the app's backup server behind evictus. The module and the relay are the
# app author's, unpacked from their tarball into elaread-translate/ (see the
# README there) - only the wiring here is ours. No container, no serve proxy.
{ config, pkgs, inputs, ... }:

let
	facts = import ../../../facts.nix;
	unstable = import inputs.nixpkgs-unstable {
		system = pkgs.stdenv.hostPlatform.system;
		config.allowUnfree = true;
	};
in
{
	imports = [ ./elaread-translate/nixos.nix ];

	services.elaread-translate = {
		enable = true;
		# Runs as the logged-in user, with the same claude the home installs
		# (modules/user/agents): one login, one version touching ~/.claude.
		user = config.dotfiles.user;
		package = unstable.claude-code;
		listen = "${facts.hosts.aorus.ts_ipv4}:8787";
		# The author's nodes (evictus, the phone eparadigm, efog), plus this box
		# so /health can be checked from here: a local connection to the tailnet
		# address arrives from that address, not from 127.0.0.1.
		allow = [ "127.0.0.1" "100.67.0.1" "100.67.0.2" "100.67.0.3" facts.hosts.aorus.ts_ipv4 ];
		# Would be a no-op anyway: aorus runs without the host firewall.
		openFirewall = false;
	};
}
