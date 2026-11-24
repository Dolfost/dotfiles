# Docs: the tailnet guide (docs/ at the repo root), rendered by mdBook at build
# time and served from the store as https://docs.<tailnet> (../tailscale), so
# the guide stays up while aorus sleeps through an outage.
#
# Its "Замовити" page (docs/src/request.md) posts to /request/<kind> here,
# and Caddy hands that to ntfy next door, topic tailscale-requests, with the
# kind in the title and two things the page cannot be trusted with: the
# token, and who is asking (tailscale serve puts the tailnet user in
# Tailscale-User-Name; Caddy is on loopback only, so nothing else can set it).
#
# The account it publishes as, requests-pub, is declared here rather than
# made by hand in ntfy's database: write-only on that topic, a password
# nobody has (the hash below is of random bytes, thrown away), and one
# token, the same sops secret Caddy sends. The token is ntfy's format,
# tk_ and 29 of [a-z0-9]:
#   sops set nix/secrets-tissot.yaml '["ntfy"]["requests-token"]' \
#     "\"tk_$(tr -dc a-z0-9 < /dev/urandom | head -c 29)\""
{ config, pkgs, ... }:

let
	port = 8090;
	kinds = [ "music" "films" "other" ];
	site = pkgs.runCommand "tailnet-docs"
		{ nativeBuildInputs = [ pkgs.mdbook ]; } ''
		mdbook build --dest-dir $out ${../../../../docs}
	'';
in
{
	sops.secrets."ntfy/requests-token" = { };
	sops.templates."caddy-env".content = ''
		NTFY_REQUESTS_TOKEN=${config.sops.placeholder."ntfy/requests-token"}
	'';
	sops.templates."ntfy-env".content = ''
		NTFY_AUTH_TOKENS=requests-pub:${config.sops.placeholder."ntfy/requests-token"}:docs
	'';

	services.ntfy-sh = {
		environmentFile = config.sops.templates."ntfy-env".path;
		settings = {
			auth-users = [ "requests-pub:$2y$10$QO4/kAU07nJCiF/gHa43ieDgcvOla4rYLBm8vzY9CPRGiB4o0cI.6:user" ];
			auth-access = [ "requests-pub:tailscale-requests:wo" ];
		};
	};

	services.caddy = {
		enable = true;
		environmentFile = config.sops.templates."caddy-env".path;
		virtualHosts."http://:${toString port}".extraConfig = ''
			# Loopback only: tailscale serve is the one way in, so the
			# Tailscale-User-Name it sets can be believed.
			bind 127.0.0.1
			@request {
				method POST
				path_regexp kind ^/request/(${builtins.concatStringsSep "|" kinds})$
			}
			handle @request {
				request_body {
					max_size 4KB
				}
				# The trailing ? drops the query: ntfy reads options from it too.
				rewrite * /tailscale-requests?
				reverse_proxy 127.0.0.1:2586 {
					header_up Authorization "Bearer {$NTFY_REQUESTS_TOKEN}"
					header_up Title "{re.kind.1} - {header.Tailscale-User-Name}"
					# A request is text and nothing else: no buttons, links,
					# attachments or mail riding along from the browser.
					header_up -Actions
					header_up -X-Actions
					header_up -Action
					header_up -Click
					header_up -X-Click
					header_up -Attach
					header_up -X-Attach
					header_up -Email
					header_up -X-Email
					header_up -Call
					header_up -X-Call
				}
			}
			handle /request/* {
				respond 404
			}
			handle {
				root * ${site}
				file_server
			}
		'';
	};
}
