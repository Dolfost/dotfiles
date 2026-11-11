# ntfy: push notifications, plain HTTP on :2586 for the LAN, and
# https://ntfy.<tailnet> as a Tailscale service (../tailscale). Users
# and tokens live in its database (`ntfy user`, `ntfy token`, run as root
# with -c /etc/ntfy/server.yml); the UPS notifier's token is in sops
# (power/notify.nix).
{ ... }:

let
	facts = import ../../../facts.nix;
in
{
	services.ntfy-sh = {
		enable = true;
		settings = {
			base-url = "https://ntfy.${facts.ts_network}";
			listen-http = ":2586";
			behind-proxy = true;
			cache-file = "/var/lib/ntfy-sh/cache.db";
			auth-file = "/var/lib/ntfy-sh/user.db";
			auth-default-access = "deny-all";
			enable-login = true;
		};
	};
}
