# Pi-hole: DNS for the LAN (the router hands the phone's address out) and
# the tailnet (the Tailscale global nameserver). Web UI at :8080.
{ ... }:

{
	services.pihole-ftl = {
		enable = true;
		settings = {
			dns = {
				# Every address of the phone, for every client: the tailnet is
				# not a local subnet to FTL, so not LOCAL.
				listeningMode = "ALL";
				upstreams = [ "1.1.1.1" "9.9.9.9" ];
			};
		};
		lists = [
			{
				url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
				description = "Steven Black's unified hosts";
			}
		];
	};
	services.pihole-web = {
		enable = true;
		ports = [ 8080 ];
	};
}
