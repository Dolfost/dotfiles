# Services aorus hosts: rootless podman quadlets, and the tailscale serve
# proxies that expose them on the tailnet.
{ config, lib, ... }:

let
	inherit (lib) mapAttrs' nameValuePair;

	facts = import ./../facts.nix;

	# svc:<name> -> localhost:<port>. Default is an HTTPS proxy on 443 to a plain
	# HTTP backend. Two escape hatches:
	#   tcp    = <port>   raw TCP forward instead of HTTPS (DNS, minecraft)
	#   scheme = "..."    backend is not plain http (crafty serves self-signed
	#                     TLS, so it needs https+insecure)
	tailscaleServices = {
		jellyfin = { port = 8096; };
		paperless = { port = 8000; };
		navidrome = { port = 4533; };
		immich = { port = 2283; };
		gitea = { port = 3000; };
		crafty = { port = 8443; scheme = "https+insecure"; };
		mc = { port = 25565; tcp = 25565; };
	};

	# Immich is three units sharing one state dir, so the same drop-in is
	# generated for each rather than written out three times.
	immichDir = "/storage/2.5/media/immich";
	mkImmichDropIn = unit:
		nameValuePair "systemd/user/${unit}.service.d/env.conf" {
			text = ''
[Service]
Environment=IMMICH_DIR=${immichDir}
'';
		};
	immichDropIns = lib.listToAttrs (map mkImmichDropIn [
		"immich-server" "immich-postgres" "immich-ml"
	]);

	mkServe = name: cfg:
	let
		mode = if cfg ? tcp
			then "--tcp=${toString cfg.tcp}"
			else "--https=443";
		port = if cfg ? scheme
			then "${cfg.scheme}://127.0.0.1:${toString cfg.port}"
			else toString cfg.port;
	in nameValuePair "tailscale-serve-${name}" {
		description = "tailscale serve: svc:${name} ${mode} -> ${port}";
		after = [ "tailscaled.service" ];
		wants = [ "tailscaled.service" ];
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
			Restart = "on-failure";
			RestartSec = 15;
			ExecStart = "${config.services.tailscale.package}/bin/tailscale "
				+ "serve --yes --service=svc:${name} ${mode} ${port}";
		};
		unitConfig.StartLimitIntervalSec = 0;
	};
in {

	virtualisation.podman.enable = true;
	users.users.${config.dotfiles.user}.linger = true;

	# Pi-hole is rootless but publishes on the real :53. Without this the bind
	# fails outright - unprivileged ports start at 1024 by default. (Arch does
	# the same from /etc/sysctl.d/99-rootless-dns.conf.)
	boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 53;

	# Quadlets that declare After=network-online.target make podman generate a
	# podman-user-wait-network-online.service that polls until that target is
	# active. Nothing pulls the target in by default, so it never activates and
	# every container unit sits in the job queue until the poller times out.
	# Wanting it here pulls in NetworkManager-wait-online, which activates it.
	systemd.targets.network-online.wantedBy = [ "multi-user.target" ];

	systemd.services = mapAttrs' mkServe tailscaleServices;

	home-manager.users.${config.dotfiles.user} = { config, ... }:
	let
		link = path: {
			source = config.lib.file.mkOutOfStoreSymlink
				"${config.dotfiles.dir}/${path}";
		};
	in {
		xdg.configFile = {
			"containers/systemd" = link "containers/systemd";
			"containers/nicotine" = link "containers/nicotine";
			"systemd/user/jellyfin.service.d/env.conf".text = ''
[Service]
Environment=JELLYFIN_DIR=/storage/2.5/media/jellyfin
Environment=JELLYFIN_MOVIES=/storage/2.5/media/movies
Environment=JELLYFIN_SHOWS=/storage/2.5/media/shows
Environment=JELLYFIN_SHOWS_HDD=/storage/3.5/media/shows
Environment=JELLYFIN_MUSIC=/storage/2.5/media/music
Environment=JELLYFIN_BOOKS=/storage/2.5/media/books
'';
			# NICOTINE_DOWNLOADS is /storage/data, which Arch reaches through a
			# ~/data symlink — same directory on the same disk either way.
			"systemd/user/nicotine.service.d/env.conf".text = ''
[Service]
Environment=NICOTINE_DIR=/storage/2.5/nicotine
Environment=NICOTINE_DOWNLOADS=/storage/data/soulseek
Environment=NICOTINE_BIND_IP=${facts.ts_ipv4}
Environment=NICOTINE_SHARE_BOOKS=/storage/2.5/media/books
Environment=NICOTINE_SHARE_MOVIES=/storage/2.5/media/movies
Environment=NICOTINE_SHARE_MUSIC=/storage/2.5/media/music
Environment=NICOTINE_SHARE_OLD_MUSIC=/storage/2.5/media/old_music
Environment=NICOTINE_SHARE_SHOWS=/storage/2.5/media/shows
Environment=NICOTINE_SHARE_SHOWS_HDD=/storage/3.5/media/shows
'';
			"systemd/user/navidrome.service.d/env.conf".text = ''
[Service]
Environment=NAVIDROME_DIR=/storage/2.5/media/navidrome
Environment=NAVIDROME_MUSIC=/storage/2.5/media/music
Environment=NAVIDROME_OLD_MUSIC=/storage/2.5/media/old_music
'';
			"systemd/user/paperless.service.d/env.conf".text = ''
[Service]
Environment=PAPERLESS_DIR=/storage/2.5/media/paperless
'';
			"systemd/user/gitea.service.d/env.conf".text = ''
[Service]
Environment=GITEA_DIR=/storage/2.5/gitea
'';
			"systemd/user/crafty.service.d/env.conf".text = ''
[Service]
Environment=CRAFTY_DIR=/storage/data/crafty
'';
			"systemd/user/pihole.service.d/env.conf".text = ''
[Service]
Environment=PIHOLE_DIR=/storage/2.5/pihole
Environment=PIHOLE_TS_IP=${facts.ts_ipv4}
Environment=PIHOLE_LAN_IP=${facts.lan_ipv4}
'';
		} // immichDropIns;
	};
}
