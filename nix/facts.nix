# The personal network, described once. Every machine on the tailnet /
# wireguard gets an entry; the tailscale name is always "d" + the machine name
# (aorus -> daorus). Hosts read their own entry (facts.hosts.aorus), the ssh
# module reads the whole fleet.
let
	machines = {
		aorus = {
			ts_ipv4 = "100.91.220.75";
			lan_ipv4 = "192.168.0.70";
		};
		loq = {
			ts_ipv4 = "100.76.130.38";
			lan_ipv4 = "192.168.0.73";
			lan_wifi_ipv4 = "192.168.0.74";
		};
		# Phones run sshd under termux: their own user, port 8022.
		rodin = {
			user = "u0_a319";
			port = 8022;
		};
		tissot = {
			user = "u0_a181";
			port = 8022;
		};
	};
in
{
	ts_network = "faun-castor.ts.net";
	hosts = builtins.mapAttrs
		(name: machine: machine // { ts_hostname = "d" + name; })
		machines;
}
