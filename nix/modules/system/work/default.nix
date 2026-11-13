# Work: the auf ground station side. Everything that touches the DigiQ
# SkyPulse radio (video port, WireGuard through it) lives in ./wireguard.nix.
{ ... }: {
	imports = [ ./wireguard.nix ];

	services.netbird.enable = true;
	# 35354: the auf protocol/video UDP port of the old ground daemon. 7400-7899:
	# ROS 2 (DDS) discovery + data from the air boards on the lab LAN. A DDS
	# domain d owns the ports 7400 + 250*d .. +249 (multicast and unicast
	# discovery, then two per participant for the data): domain 0 is the
	# development graph on this machine, domain 1 jet1's auf unit, domain 2
	# jet2's
	# (every air unit gets its own domain, see auf/ros/deploy/README.md). Without
	# them the ground GUI never sees the board's nodes.
	networking.firewall.allowedUDPPorts = [ 35354 ];
	# 7000-7399: the node NAMES. rmw_fastrtps reads its graph topic
	# (ros_discovery_info) through a Fast DDS "unique network flow", a dedicated
	# UDP socket per ROS process bound in portBase-400..portBase whatever the
	# domain. Closed, every topic and service still works but `ros2 node list`
	# and `ros2 param` against the board stay empty (2026-11-03).
	networking.firewall.allowedUDPPortRanges = [
		{ from = 7000; to = 7399; }
		{ from = 7400; to = 8149; }
	];
}
