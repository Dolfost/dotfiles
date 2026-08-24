# Literal facts about this machine that Nix cannot derive from config, and that
# would otherwise get hardcoded into git-tracked container files.
{
	hostName = "aorus";

	# tailnet identity
	tailnet = "faun-castor.ts.net";
	tsHostName = "daorus";
	tsIp4 = "100.91.220.75";

	# Pi-hole binds this so the router can hand it out as the DHCP DNS server,
	# which also means it must stay pinned in the router's lease table.
	lanIp4 = "192.168.0.70";
}
