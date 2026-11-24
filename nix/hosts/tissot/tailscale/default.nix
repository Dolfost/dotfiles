# The tailnet node for the phone lives here, not on the Alpine host: the
# guest shares the host's network namespace, so tailscale0 is the phone's
# for every service on it. /dev/net/tun and CAP_NET_ADMIN come from the
# .nspawn unit (pmos/etc/systemd/nspawn/nixos.nspawn).
#
# Tailscale services front the local ones with their own names and
# certificates on the tailnet, as on aorus (hosts/aorus/services): ntfy is
# https://ntfy.<tailnet>, Pi-hole's web UI https://pihole.<tailnet>, the
# guide https://docs.<tailnet> (services/docs.nix), and
# https://dash.<tailnet> is Elamon's page (power/elamon.nix): elamond serves
# it over HTTPS with a certificate of its own, which only loopback sees, so
# serve does not check it. The service itself is made in the admin console;
# the serve config lives in tailscaled's state, so each oneshot is idempotent.
{ config, lib, ... }:

let
	tailscale = "${config.services.tailscale.package}/bin/tailscale";
	serve = svc: target: {
		"tailscale-serve-${svc}" = {
			description = "tailscale serve: svc:${svc} https -> ${target}";
			after = [ "tailscaled.service" ];
			wants = [ "tailscaled.service" ];
			wantedBy = [ "multi-user.target" ];
			serviceConfig = {
				Type = "oneshot";
				RemainAfterExit = true;
				Restart = "on-failure";
				RestartSec = 15;
				ExecStart = "${tailscale} serve --yes --service=svc:${svc} --https=443 ${target}";
			};
			unitConfig.StartLimitIntervalSec = 0;
		};
	};
in
{
	services.tailscale = {
		enable = true;
		openFirewall = true;
	};

	systemd.services = lib.mkMerge [
		(serve "ntfy" "http://127.0.0.1:2586")
		(serve "pihole" "http://127.0.0.1:8080")
		(serve "docs" "http://127.0.0.1:8090")
		(serve "dash" "https+insecure://127.0.0.1:${toString config.services.elamond.settings.port}")
	];
}
