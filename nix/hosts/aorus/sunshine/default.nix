# Sunshine host knowledge: the web UI origins this box answers to. Enablement
# and apps come from modules/system/gaming, capture and the virtual display app
# from the desktop modules.
{ lib, ... }:

let
	facts = import ../../../facts.nix;
	me = facts.hosts.aorus;
in
{
	services.sunshine.settings.csrf_allowed_origins =
		lib.concatMapStringsSep "," (h: "https://${h}:47990") [
			"${me.ts_hostname}.${facts.ts_network}"
			"${me.ts_hostname}.wg"
			"10.8.0.4"
		];
}
