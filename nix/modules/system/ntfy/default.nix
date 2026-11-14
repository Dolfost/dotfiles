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

	# `ntfy-ask QUESTION OPTION OPTION [OPTION]`: a question on the `claude`
	# topic with one button per option, then wait for the tap and print the
	# choice (Claude Code's notify skill, claude/skills/notify). A button is an
	# ntfy http action: the phone itself posts "<id>:<n>" to `claude-reply`,
	# so the notification has to carry a token. That one is claude-pub's,
	# which can only write to those two topics, never the fleet's. The random
	# id keeps concurrent questions apart. ntfy allows three buttons at most.
	#   exit 0: "<n>) <option>" on stdout    exit 2: nobody tapped in time
	ntfy-ask = pkgs.writeShellScriptBin "ntfy-ask" ''
		set -euo pipefail
		timeout=3600
		if [ "''${1:-}" = "-t" ]; then timeout="$2"; shift 2; fi
		[ $# -ge 3 ] && [ $# -le 4 ] || { echo "usage: ntfy-ask [-t SECONDS] QUESTION OPTION OPTION [OPTION]" >&2; exit 1; }
		question="$1"; shift
		curl=${pkgs.curl}/bin/curl jq=${pkgs.jq}/bin/jq
		auth="Authorization: Bearer $(cat ${cfg.tokenFile})"
		reply_token="$(cat ${cfg.replyTokenFile})"
		id="$(head -c 6 /dev/urandom | od -An -tx1 | tr -d ' \n')"
		body="$question" actions="" n=0
		for option in "$@"; do
			n=$((n + 1))
			body="$body"$'\n'"$n) $option"
			actions="$actions''${actions:+; }http, Option $n, ${cfg.url}/claude-reply, method=POST, headers.Authorization=Bearer $reply_token, body=$id:$n, clear=true"
		done
		sent="$($curl -fsS -m 10 -H "$auth" -H "Title: $(hostname): Claude asks" -H "Actions: $actions" \
			--data-binary "$body" "${cfg.url}/claude" | $jq -r .time)"
		IFS= read -r answer < <($curl -sS -N -m "$timeout" -H "$auth" "${cfg.url}/claude-reply/json?since=$sent" 2>/dev/null \
			| $jq --unbuffered -r --arg p "$id:" 'select(.event == "message") | .message | select(startswith($p)) | ltrimstr($p)') || true
		case "''${answer:-}" in
			[1-9]) [ "$answer" -le $# ] && { echo "$answer) ''${!answer}"; exit 0; } ;;
		esac
		echo "no answer within $timeout s" >&2
		exit 2
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
		replyTokenFile = mkOption {
			type = types.str;
			default = config.sops.secrets."ntfy/reply-token".path;
			description = "A file with claude-pub's token, for the buttons of ntfy-ask.";
		};
	};

	config = mkIf cfg.enable {
		sops.secrets."ntfy/token" = {
			sopsFile = ../../../secrets-tissot.yaml;
			# The wheel group runs ntfy-cmd without sudo.
			group = "wheel";
			mode = "0440";
		};
		sops.secrets."ntfy/reply-token" = {
			sopsFile = ../../../secrets-tissot.yaml;
			group = "wheel";
			mode = "0440";
		};
		environment.systemPackages = [ ntfy-cmd ntfy-ask ];
	};
}
