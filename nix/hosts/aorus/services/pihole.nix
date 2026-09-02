# Pi-hole: DNS for the LAN and tailnet, straight on :53 (no serve proxy).
{ config, ... }:

let
	facts = import ../facts.nix;
in
{
	# Pi-hole is rootless but publishes on the real :53. Without this the
	# bind fails outright - unprivileged ports start at 1024 by default.
	# (Arch does the same from /etc/sysctl.d/99-rootless-dns.conf.)
	boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 53;

	home-manager.users.${config.dotfiles.user}.xdg.configFile
		."systemd/user/pihole.service.d/env.conf".text = ''
[Service]
Environment=PIHOLE_DIR=/storage/2.5/pihole
Environment=PIHOLE_TS_IP=${facts.ts_ipv4}
Environment=PIHOLE_LAN_IP=${facts.lan_ipv4}
'';
}
