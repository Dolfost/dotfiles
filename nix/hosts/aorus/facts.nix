# Literal facts about this machine that Nix cannot derive from config, and that
# would otherwise get hardcoded into git-tracked container files.
{
	hostName = "aorus";

	# tailnet identity
	tailnet = "faun-castor.ts.net";
	tsHostName = "daorus";
	tsIp4 = "100.91.220.75";
}
