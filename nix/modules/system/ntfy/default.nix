# The ntfy server on the phone (hosts/tissot/services/ntfy.nix), from the
# command line of any machine: `ntfy-cmd TOPIC MESSAGE` publishes with the
# fleet's token, which every host reads from the phone's secrets file
# (.sops.yaml lists their keys). Notifications only: what there is to do
# about an outage is on the phone's dashboard (hosts/tissot/power/dashboard.nix).
{ config, lib, pkgs, ... }:

let
	cfg = config.dotfiles.ntfy;
	facts = import ../../../facts.nix;
	inherit (lib) mkOption mkIf types;
	ntfy-cmd = pkgs.writeShellScriptBin "ntfy-cmd" ''
		topic="$1"; shift
		[ -n "$topic" ] && [ $# -gt 0 ] || { echo "usage: ntfy-cmd TOPIC MESSAGE..." >&2; exit 1; }
		exec ${pkgs.curl}/bin/curl -fsS -m 10 -o /dev/null \
			-H "Authorization: Bearer $(cat ${cfg.tokenFile})" -d "$*" "${cfg.url}/$topic"
	'';
in
{
	options.dotfiles.ntfy = {
		enable = mkOption {
			type = types.bool;
			default = false;
			description = "ntfy-cmd and the publishing token on this host.";
		};
		url = mkOption {
			type = types.str;
			default = "https://ntfy.${facts.ts_network}";
			description = "The ntfy server, as this host reaches it.";
		};
		tokenFile = mkOption {
			type = types.str;
			default = config.sops.secrets."ntfy/token".path;
			description = "A file with a token allowed to publish.";
		};
	};

	config = mkIf cfg.enable {
		sops.secrets."ntfy/token" = {
			sopsFile = ../../../secrets-tissot.yaml;
			# The wheel group runs ntfy-cmd without sudo.
			group = "wheel";
			mode = "0440";
		};
		environment.systemPackages = [ ntfy-cmd ];
	};
}
